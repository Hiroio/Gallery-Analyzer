//
//  PhotoManager.swift
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

final class PhotoManager {
  static let shared = PhotoManager()
  
  var allMedia: [MediaFile] = []
  
  private init() {
  }
  
  //  MARK:  Check for currnet status of authorization
  func checkCurrentStatus() async -> Bool {
    let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
    if (status == .authorized || status == .limited){
      return true
    }
    return await requestAccess()
  }
  
  //  MARK:  Request Authorization
  @MainActor
  func requestAccess() async -> Bool {
    let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
    return (status == .authorized || status == .limited)
  }
  
  //   MARK: Fetch
  func fetchAllGalleryItems() async -> [MediaFile] {
      let options = PHFetchOptions()
      options.includeAssetSourceTypes = [.typeUserLibrary]
      
      let fetchResult = PHAsset.fetchAssets(with: options)
      let totalCount = fetchResult.count
      let chunkSize = 300
      
      return await withTaskGroup(of: [MediaFile].self) { group in
          var allFiles: [MediaFile] = []
          allFiles.reserveCapacity(totalCount)
          
          for start in stride(from: 0, to: totalCount, by: chunkSize) {
              let end = min(start + chunkSize, totalCount)
              
              group.addTask(priority: .userInitiated) {
                  var chunkFiles: [MediaFile] = []
                  for i in start..<end {
                      let asset = fetchResult.object(at: i)
                    await chunkFiles.append(MediaFile(asset: asset))
                  }
                  return chunkFiles
              }
          }
          
          for await chunk in group {
              allFiles.append(contentsOf: chunk)
          }
          
          return allFiles
      }
  }
  
  func deleteMediaItems(_ items: [MediaFile]) async -> Bool {
      let assetsToDelete = items.map { $0.asset }
      
      return await withCheckedContinuation { continuation in
          PHPhotoLibrary.shared().performChanges({
              PHAssetChangeRequest.deleteAssets(assetsToDelete as NSArray)
          }) { success, error in
              if let error = error {
                  print("Failed to delete: \(error.localizedDescription)")
              }
              continuation.resume(returning: success)
          }
      }
  }
  
  func converByteToHumanReadable(_ bytes:Int64) -> String {
       let formatter:ByteCountFormatter = ByteCountFormatter()
       formatter.countStyle = .binary
       
       return formatter.string(fromByteCount: Int64(bytes))
   }
}
