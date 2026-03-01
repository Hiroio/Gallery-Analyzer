//
//  MainViewModel.swift
//  Compressor
//
//  Created by Vlad Sadovnyk on 01.03.2026.
//  Copyright © 2026 Vlad Sadovnyk. All rights reserved.
//
//  Licensed under the MIT License. See LICENSE file in the project root for full license information.
//

import Foundation
import Combine
import Photos

@MainActor
class MainViewModel: ObservableObject{
  static let shared = MainViewModel()
  @Published var isAuthorized = false
  
  
  @Published var mediaCount: Int? = nil
  @Published var mediaSize: Double? = nil
  @Published var videosCount: Int? = nil
  @Published var videoSize: Double? = nil
  
  
  
  @Published var allMedia: [MediaFile] = []
  
  
  private let photoManager = PhotoManager.shared
  private let analysisManager = MediaAnalysisActor.shared
  
  init(){
    DispatchQueue.main.asyncAfter(deadline: .now() + 1){
      self.checkAuth()
    }
  }
  
  func checkAuth() {
    Task{
      let auth = await photoManager.checkCurrentStatus()
      isAuthorized = auth
      UserDefaults.standard.setValue(auth, forKey: "isAuthorized")
      if auth{
        await fetchAndPrepareData()
      }
    }
  }
  
  func fetchAndPrepareData() async {
      let media = await photoManager.fetchAllGalleryItems()
      
      let stats = await Task.detached(priority: .userInitiated) {
          let vCount = media.filter { $0.isVideo }.count
          return (vCount: vCount, mCount: media.count)
      }.value
      
      await MainActor.run {
          self.allMedia = media
          self.mediaCount = stats.mCount
          self.videosCount = stats.vCount
      }
      calculateSizes(for: media)
  }

  private func calculateSizes(for media: [MediaFile]) {
      Task.detached(priority: .userInitiated) {
          var updatedMedia = media
          var totalSize: Int64 = 0
          var videoSize: Int64 = 0
          
          for index in updatedMedia.indices {
              let asset = updatedMedia[index].asset
              let resources = PHAssetResource.assetResources(for: asset)
              
              if let resource = resources.first {
                  let size = resource.value(forKey: "fileSize") as? Int64 ?? 0
                  
                  updatedMedia[index].fileSize = size
                  
                  totalSize += size
                  if updatedMedia[index].isVideo {
                      videoSize += size
                  }
              }
//              BATCH
              if index % 200 == 0 {
                  let currentMedia = updatedMedia
                  let currentTotal = totalSize
                  let currentVideo = videoSize
                  
                  await MainActor.run {
                      self.allMedia = currentMedia
                      self.mediaSize = Double(currentTotal) / 1_000_000_000
                      self.videoSize = Double(currentVideo) / 1_000_000_000
                  }
              }
          }
          
          let finalMedia = updatedMedia
          let finalTotal = totalSize
          let finalVideo = videoSize
          
          await MainActor.run {
              self.allMedia = finalMedia
              self.mediaSize = Double(finalTotal) / 1_000_000_000
              self.videoSize = Double(finalVideo) / 1_000_000_000
          }
      }
  }
}
