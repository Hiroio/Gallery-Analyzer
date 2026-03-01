//
//  AnalysisManager.swift
//  Compressor
//
//  Created by Vlad Sadovnyk on 01.03.2026.
//  Copyright © 2026 Vlad Sadovnyk. All rights reserved.
//
//  Licensed under the MIT License. See LICENSE file in the project root for full license information.
//

import Foundation
import UIKit
import Combine
import Photos

actor MediaAnalysisActor {
  static let shared = MediaAnalysisActor()
  
  // results
  @Published var exactDuplicates: [Int64: [MediaFile]] = [:]
  @Published var similarImages: [String: [MediaFile]] = [:]
  @Published var screenshots: [MediaFile] = []
  @Published var screenRecordings: [MediaFile] = []
  @Published var livePhotos: [MediaFile] = []
  
  private let imageManager = PHImageManager.default()
  
  private init() {}
  
  func startFullAnalysis(files: [MediaFile]) async {
      await processMetadataCategories(files: files)
  }
  
}

extension MediaAnalysisActor{
  func processMetadataCategories(files: [MediaFile]) async {
      var tempScreenshots: [MediaFile] = []
      var tempRecordings: [MediaFile] = []
      var tempLive: [MediaFile] = []
      
      for file in files {
          let asset = file.asset
        
//        MARK: ScreenShots
          if asset.mediaSubtypes.contains(.photoScreenshot) {
              tempScreenshots.append(file)
          }
          
//        MARK: LivePhotos
          if asset.mediaSubtypes.contains(.photoLive) {
              tempLive.append(file)
          }
          
//        Mark: ScreenRecord
          if asset.mediaType == .video && asset.mediaSubtypes.contains(.videoScreenRecording) {
              tempRecordings.append(file)
          }
          
//        MARK: PAUSE
          if tempScreenshots.count % 100 == 0 {
              await Task.yield()
          }
      }
      
      self.screenshots = tempScreenshots
      self.livePhotos = tempLive
      self.screenRecordings = tempRecordings
      
  }
}

extension MediaAnalysisActor{
  func prepareHashes(for media: [MediaFile]) async -> [MediaFile] {
      var updatedMedia = media
      let manager = PHImageManager.default()
      let options = PHImageRequestOptions()
      options.isSynchronous = true
      options.deliveryMode = .fastFormat
      options.isNetworkAccessAllowed = false

      return await withTaskGroup(of: (Int, UInt64?).self) { group in
          for index in updatedMedia.indices where !updatedMedia[index].isVideo {
              group.addTask {
                  let asset = updatedMedia[index].asset
                  var hash: UInt64? = nil
                  
                  manager.requestImage(for: asset,
                                       targetSize: CGSize(width: 8, height: 8),
                                       contentMode: .aspectFill,
                                       options: options) { image, _ in
                      if let uiImage = image {
                          hash = uiImage.dHash()
                      }
                  }
                  return (index, hash)
              }
          }

          for await (index, hash) in group {
              updatedMedia[index].imageHash = hash
          }
          return updatedMedia
      }
  }
  
}

extension MediaAnalysisActor {
    func scanVideosForSimilars(files: [MediaFile]) async -> [String: [MediaFile]] {
        var videoHashes: [String: [MediaFile]] = [:]
        
        for file in files {
            if let vHash = await generateVideoHash(for: file.asset) {
                videoHashes[vHash, default: []].append(file)
            }
        }
        
        return videoHashes.filter { $0.value.count > 1 }
    }
    
    private func generateVideoHash(for asset: PHAsset) async -> String? {
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .fastFormat
        
        return await withCheckedContinuation { continuation in
            PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { avAsset, _, _ in
                guard let avAsset = avAsset else {
                    continuation.resume(returning: nil)
                    return
                }
                
                Task {
                    do {
                        let duration = try await avAsset.load(.duration)
                        let seconds = CMTimeGetSeconds(duration)
                        
                        let generator = AVAssetImageGenerator(asset: avAsset)
                        generator.appliesPreferredTrackTransform = true
                        
                        let time = CMTime(seconds: seconds * 0.1, preferredTimescale: 60)
                        
                        let cgImage = try generator.copyCGImage(at: time, actualTime: nil)
                        let uiImage = UIImage(cgImage: cgImage)
                        
                      if let dHash = await uiImage.dHash() {
                            let key = "\(dHash)_\(Int(seconds))_\(asset.pixelWidth)x\(asset.pixelHeight)"
                            continuation.resume(returning: key)
                        } else {
                            continuation.resume(returning: nil)
                        }
                    } catch {
                        print("failed to load video \(error)")
                        continuation.resume(returning: nil)
                    }
                }
            }
        }
    }
}
