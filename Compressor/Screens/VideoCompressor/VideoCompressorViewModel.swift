//
//  VideoCompressorViewModel.swift
//  Compressor
//
//  Created by Vlad Sadovnyk on 01.03.2026.
//  Copyright © 2026 Vlad Sadovnyk. All rights reserved.
//
//  Licensed under the MIT License. See LICENSE file in the project root for full license information.
//

import Foundation
import Combine
import SwiftUI
import Photos
import AVKit

@MainActor
class VideoCompressorViewModel: ObservableObject {
  // MARK: - Published Properties
  @Published var videos: [MediaFile] = []
  @Published var isLoading = false
  @Published var selectedOption: CompressOptions = .low
  
  @Published var player: AVPlayer?
  
//  For UI
  @Published var isCompressing = false
  @Published var compressionProgress: Double = 0
  @Published var compressedSize: Double = 0
  @Published var compressedURL: URL?
  @Published var screenState: CompressorState = .selection
  
  private var cancellables = Set<AnyCancellable>()
  private let compressManager = VideoCompressorManager.shared
  private let mainVM = MainViewModel.shared
  // MARK: - Lifecycle
  init() {
    mainVM.$allMedia
      .receive(on: RunLoop.main)
      .sink { [weak self] files in
        self?.videos = files.filter{ $0.isVideo }
      }
      .store(in: &cancellables)
  }
  
  // MARK: - Data Logic
  func fetchVideos() {
    self.isLoading = true
    self.isLoading = false
  }
  
  func calculateWillBeSize(for itemSize: Double, option: CompressOptions) -> Double {
    var multiplier: Double
    switch  option{
    case .low: multiplier = 0.3
    case .medium: multiplier = 0.5
    case .high: multiplier = 0.8
    }
    return itemSize * multiplier
  }
  
  
  //  MARK: PlayerLogic
  func setupPlayerForAsset(_ asset: PHAsset) {
    self.player?.pause()
    
    let options = PHVideoRequestOptions()
    options.isNetworkAccessAllowed = true
    
    PHImageManager.default().requestPlayerItem(forVideo: asset, options: options) { [weak self] item, _ in
      DispatchQueue.main.async {
        if let playerItem = item {
          self?.player = AVPlayer(playerItem: playerItem)
        }
      }
    }
  }
  
  func setupPlayer(for url: URL) {
    self.player?.pause()
    self.player = AVPlayer(url: url)
  }
  
  // MARK: - Compression Logic
  func startCompression(for item: MediaFile, quality: CompressOptions) async {
    guard !isCompressing else { return }
    
    isCompressing = true
    compressionProgress = 0
    screenState = .loading
    player = nil
    do {
      let resultURL = try await compressManager.compressVideo(
        asset: item.asset,
        quality: quality
      ) { progress in
        Task { @MainActor in
          self.compressionProgress = progress
        }
      }
      
      self.compressedURL = resultURL
      let values = try resultURL.resourceValues(forKeys: [.fileSizeKey])
      self.compressedSize = Double(Int64(values.fileSize ?? 0)) / 1_000_000
      
      setupPlayer(for: resultURL)
      
      withAnimation {
        self.isCompressing = false
        self.screenState = .result
      }
    } catch {
      print("Compression error: \(error.localizedDescription)")
      isCompressing = false
    }
  }
  
  func cancel(){
    compressManager.cancelCompression()
    isCompressing = false
    screenState = .selection
  }
  
  func finalizeCompression(deleteOriginal: Bool, item: MediaFile) async {
    guard let url = compressedURL else { return }
    let mainVM = MainViewModel.shared
    player = nil
    
    do {
//      saving new video
      guard let newAssetID = try await compressManager.saveToLibrary(tempURL: url) else { return }
      guard let newAsset = PHAsset.fetchAssets(withLocalIdentifiers: [newAssetID], options: nil).firstObject else { return }
      
      var newMediaFile = MediaFile(asset: newAsset)
      let resources = PHAssetResource.assetResources(for: newAsset)
      newMediaFile.fileSize = resources.first?.value(forKey: "fileSize") as? Int64 ?? 0
      
      await MainActor.run {
        mainVM.allMedia.append(newMediaFile)
        
        if deleteOriginal {
          Task {
            try? await compressManager.deleteOriginal(asset: item.asset)
            await MainActor.run {
              mainVM.allMedia.removeAll { $0.id == item.id }
            }
          }
        }
        self.screenState = .selection
        self.compressedURL = nil
      }
    } catch {
      print("Error: \(error)")
    }
  }
  
}
