//
//  CompressOptions.swift
//  Compressor
//
//  Created by Vlad Sadovnyk on 01.03.2026.
//  Copyright © 2026 Vlad Sadovnyk. All rights reserved.
//
//  Licensed under the MIT License. See LICENSE file in the project root for full license information.
//

import Foundation
import AVFoundation


enum CompressOptions: String, CaseIterable, Identifiable{
  case low, medium, high
  
  var id: String{
    self.rawValue
  }
  var text: String{
    switch self {
    case .low:
      "Low quality"
    case .medium:
      "Medium quality"
    case .high:
      "High quality"
    }
  }
  
  var avPreset: String {
          switch self {
          case .low: return AVAssetExportPreset640x480
          case .medium: return AVAssetExportPreset960x540
          case .high: return AVAssetExportPreset1280x720
          }
      }
}


enum CompressorState{
  case selection, loading, result
}
