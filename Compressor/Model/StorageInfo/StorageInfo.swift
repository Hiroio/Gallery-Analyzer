//
//  StorageInfo.swift
//  Compressor
//
//  Created by Vlad Sadovnyk on 01.03.2026.
//  Copyright © 2026 Vlad Sadovnyk. All rights reserved.
//
//  Licensed under the MIT License. See LICENSE file in the project root for full license information.
//

import Foundation


struct StorageInfo: Equatable{
    var total: Int64
    var used: Int64
    var ratio: Double
    
    var usedGB: Double { Double(used) / 1_000_000_000 }
    var totalGB: Double { Double(total) / 1_000_000_000 }
    
    
  func update() -> StorageInfo{
    let path = NSHomeDirectory()
    if let attrs = try? FileManager.default.attributesOfFileSystem(forPath: path) {
      let total = attrs[.systemSize] as? Int64 ?? 0
      let free = attrs[.systemFreeSize] as? Int64 ?? 0
      let used = total - free
      return StorageInfo(total: total, used: used, ratio: (Double(used) / Double(total)))
    }
    return self
  }
}
