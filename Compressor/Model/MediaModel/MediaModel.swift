//
//  MediaModel.swift
//  Compressor
//
//  Created by Vlad Sadovnyk on 01.03.2026.
//  Copyright © 2026 Vlad Sadovnyk. All rights reserved.
//
//  Licensed under the MIT License. See LICENSE file in the project root for full license information.
//

import Foundation
import SwiftUI
import Photos

struct MediaFile: Identifiable {
    let id: String
    let asset: PHAsset
    let isVideo: Bool
    var fileSize: Int64 = 0
  var imageHash: UInt64? = nil

    init(asset: PHAsset) {
        self.id = asset.localIdentifier
        self.asset = asset
        self.isVideo = asset.mediaType == .video
    }
} 


