//
//  MediaDashBoard.swift
//  Compressor
//
//  Created by Vlad Sadovnyk on 01.03.2026.
//  Copyright © 2026 Vlad Sadovnyk. All rights reserved.
//
//  Licensed under the MIT License. See LICENSE file in the project root for full license information.
//

import Foundation


enum MediaDashBoard: String, CaseIterable, Identifiable{
  case duplicatePhoto, similarPhoto, screenshots, livephoto, screenRecording, similarVideo
  
  var id: String{
    self.rawValue
  }
  
  var icon: String{
    switch self {
    case .duplicatePhoto:
      "photo.stack.fill"
    case .similarPhoto:
      "photo.on.rectangle.angled.fill"
    case .screenshots:
      "square.dashed.inset.fill"
    case .livephoto:
      "livephoto"
    case .screenRecording:
      "rectangle.inset.filled.badge.record"
    case .similarVideo:
      "video.fill"
    }
  }
  
  var text: String{
    switch self {
    case .duplicatePhoto:
      "Duplicate Photos"
    case .similarPhoto:
      "Similar Photos"
    case .screenshots:
      "Screenshots"
    case .livephoto:
      "Live Photos"
    case .screenRecording:
      "Screen Recordings"
    case .similarVideo:
      "Similar Videos"
    }
  }
  
  var element: String{
    switch self {
    case .duplicatePhoto:
      "Duplicate"
    case .similarPhoto:
      "Similar"
    case .screenshots:
      "photos"
    case .livephoto:
      "photos"
    case .screenRecording:
      "videos"
    case .similarVideo:
      "Similar"
    }
  }
}
