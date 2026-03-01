//
//  MediaDashBoardViewModel.swift
//  Compressor
//
//  Created by Vlad Sadovnyk on 02.03.2026.
//  Copyright © 2026 Vlad Sadovnyk. All rights reserved.
//
//  Licensed under the MIT License. See LICENSE file in the project root for full license information.
//

import Foundation
import Combine

class MediaDashBoardViewModel: ObservableObject {
  @Published var allFiles: [MediaFile] = []
  @Published var screenshots: [MediaFile] = []
  @Published var similarImages: [String: [MediaFile]] = [:]
  @Published var screenRecordings: [MediaFile] = []
  @Published var livePhotos: [MediaFile] = []
  @Published var similarVideos: [String: [MediaFile]] = [:]
  @Published var exactDuplicates: [String: [MediaFile]] = [:]
  
  @Published var videosIsLoading: Bool = false
  
  
  private let analysisManager = MediaAnalysisActor.shared
  private let mainVM = MainViewModel.shared
  private var cancellables = Set<AnyCancellable>()
  
  var exactDuplicatesGrouped: [String: [MediaFile]] {
      let groupedBySize = Dictionary(grouping: allFiles) { $0.fileSize }
          .filter { $0.key > 0 && $0.value.count > 1 }
      
      var result: [String: [MediaFile]] = [:]
      
      for (_, files) in groupedBySize {
          if let firstId = files.first?.id {
              result[firstId] = files
          }
      }
      return result
  }
  
  init(){
    mainVM.$allMedia
                .receive(on: RunLoop.main)
                .sink { [weak self] files in
                    self?.allFiles = files
                }
                .store(in: &cancellables)
    
    Task{
      await analysisManager.startFullAnalysis(files: allFiles)
      self.screenshots = await analysisManager.screenshots
      self.screenRecordings = await analysisManager.screenshots
      self.livePhotos = await analysisManager.livePhotos
      let media = await analysisManager.prepareHashes(for: allFiles)
      mainVM.allMedia = media
      self.similarImages = self.getSimilarImages(allFiles: media)
    }
    }
  
//  MARK : Proccesing func
//  Duplicates
  func getDuplicatedImages() -> [String: [MediaFile]]{
    let groupedBySize = Dictionary(grouping: allFiles) { $0.fileSize }
        .filter { $0.key > 0 && $0.value.count > 1 }
    
    var result: [String: [MediaFile]] = [:]
    
    for (_, files) in groupedBySize {
        if let firstId = files.first?.id {
            result[firstId] = files
        }
    }
    
    return result
  }
  
//  Similar by hesh
  func getSimilarImages(allFiles: [MediaFile]) -> [String: [MediaFile]] {
      let photosWithHash = allFiles.filter { !$0.isVideo && $0.imageHash != nil }
      
      let grouped = Dictionary(grouping: photosWithHash) { $0.imageHash! }
      
      let duplicates = grouped.filter { $0.value.count > 1 }
      
      var result: [String: [MediaFile]] = [:]
      for (_, files) in duplicates {
          if let firstId = files.first?.id {
              result[firstId] = files
          }
      }
      
      return result
  }  
//  Similar by frame hesh and size
  func getSimilarVideos() {
    if similarVideos.isEmpty{
      Task{
        self.videosIsLoading = true
        let result = await analysisManager.scanVideosForSimilars(files: allFiles)
        self.similarVideos =  result
        self.videosIsLoading = false
      }
    }
  }
  

  
//  Delete from gallery|| end of function
  func deleteSelectedItems(items: [MediaFile], category: MediaDashBoard) {
      Task {
          let success = await PhotoManager.shared.deleteMediaItems(items)
          
          if success {
              await MainActor.run {
                  let idsToDelete = Set(items.map { $0.id })
                  
                mainVM.allMedia.removeAll(where: { idsToDelete.contains($0.id) })
                  
                  switch category {
                  case .similarPhoto:
                      self.cleanDictionary(dict: &self.similarImages, ids: idsToDelete)
                  case .duplicatePhoto:
                      self.cleanDictionary(dict: &self.exactDuplicates, ids: idsToDelete)
                  case.similarVideo:
                      self.cleanDictionary(dict: &self.exactDuplicates, ids: idsToDelete)
                  case .livephoto:
                    self.livePhotos.removeAll(where: {idsToDelete.contains($0.id)})
                  case .screenRecording:
                    self.screenRecordings.removeAll(where: {idsToDelete.contains($0.id)})
                  case .screenshots:
                    self.screenshots.removeAll(where: {idsToDelete.contains($0.id)})
                  }
                  
              }
          }
      }
  }

  
  //  Utility
    func getCount(_ option: MediaDashBoard) -> Int{
      switch option {
      case .duplicatePhoto:
        exactDuplicatesGrouped.keys.count
      case .similarPhoto:
        similarImages.count
      case .screenshots:
        screenshots.count
      case .livephoto:
        livePhotos.count
      case .screenRecording:
        screenRecordings.count
      case .similarVideo:
        similarVideos.count
      }
      
    }
  
  private func cleanDictionary(dict: inout [String: [MediaFile]], ids: Set<String>) {
      for (key, files) in dict {
          let remaining = files.filter { !ids.contains($0.id) }
          if remaining.count < 2 {
              dict.removeValue(forKey: key)
          } else {
              dict[key] = remaining
          }
      }
  }
  
}
