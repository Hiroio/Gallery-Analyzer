//
//  VideoCompressorManager.swift
//  Compressor
//
//  Created by Vlad Sadovnyk on 01.03.2026.
//  Copyright © 2026 Vlad Sadovnyk. All rights reserved.
//
//  Licensed under the MIT License. See LICENSE file in the project root for full license information.
//

import Foundation
import AVFoundation
import Photos

final class VideoCompressorManager: @unchecked Sendable {
    static let shared = VideoCompressorManager()
    private init() {
      
    }
    
    private var activeSession: AVAssetExportSession?
    private let imageManager = PHImageManager.default()
    
    func compressVideo(
        asset: PHAsset,
        quality: CompressOptions,
        onProgress: @escaping @Sendable (Double) -> Void
    ) async throws -> URL {
        
        let avAsset = try await fetchAVAsset(for: asset)
        
        guard let exportSession = AVAssetExportSession(asset: avAsset, presetName: quality.avPreset) else {
            throw NSError(domain: "Compressor", code: -1, userInfo: [NSLocalizedDescriptionKey: "Неможливо створити сесію експорту"])
        }
        
        self.activeSession = exportSession
        
        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("mp4")
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        exportSession.shouldOptimizeForNetworkUse = true
        
        // progress
        let progressTask = Task {
            while !Task.isCancelled {
                let currentProgress = Double(exportSession.progress)
                onProgress(currentProgress)
                
                if exportSession.status != .exporting && exportSession.status != .waiting { break }
                
                try? await Task.sleep(nanoseconds: 100_000_000)
            }
        }
        
//        export
        return try await withCheckedThrowingContinuation { continuation in
          nonisolated(unsafe) let session = exportSession
            session.exportAsynchronously {
                progressTask.cancel()
                self.activeSession = nil
                
                switch session.status {
                case .completed:
                    onProgress(1.0)
                    continuation.resume(returning: outputURL)
                case .failed:
                    continuation.resume(throwing: session.error ?? NSError(domain: "Compressor", code: -2))
                case .cancelled:
                    continuation.resume(throwing: CocoaError(.userCancelled))
                default:
                    continuation.resume(throwing: NSError(domain: "Compressor", code: -3))
                }
            }
        }
    }
    
    // MARK: - PhotoKit Helpers
    
    private func fetchAVAsset(for asset: PHAsset) async throws -> AVAsset {
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .highQualityFormat
        
        return try await withCheckedThrowingContinuation { continuation in
            imageManager.requestAVAsset(forVideo: asset, options: options) { avAsset, _, info in
                if let avAsset = avAsset {
                    continuation.resume(returning: avAsset)
                } else {
                    let error = info?[PHImageErrorKey] as? Error ?? NSError(domain: "Compressor", code: -4)
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Actions
    
    func cancelCompression() {
        activeSession?.cancelExport()
        activeSession = nil
    }
    
//    Save to library
  func saveToLibrary(tempURL: URL) async throws -> String? {
      var placeholderID: String?
      
      try await PHPhotoLibrary.shared().performChanges {
          let request = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: tempURL)
          placeholderID = request?.placeholderForCreatedAsset?.localIdentifier
      }
      
      return placeholderID
  }
    
// deleting from library
    func deleteOriginal(asset: PHAsset) async throws {
        try await PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.deleteAssets([asset] as NSArray)
        }
    }
}
