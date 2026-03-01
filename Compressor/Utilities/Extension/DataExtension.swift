//
//  DataExtension.swift
//  Compressor
//
//  Created by Vlad Sadovnyk on 01.03.2026.
//  Copyright © 2026 Vlad Sadovnyk. All rights reserved.
//
//  Licensed under the MIT License. See LICENSE file in the project root for full license information.
//

import Foundation
import UIKit

extension Int64{
  func toDoubleGB() -> Double{
    Double(self) / 1_000_000_000
  }
  func toDoubleMB() -> Double{
    Double(self) / 1_000_000
  }
}


extension UIImage {
    func dHash() -> UInt64? {
        let size = CGSize(width: 9, height: 8)
        UIGraphicsBeginImageContext(size)
        self.draw(in: CGRect(origin: .zero, size: size))
        
        guard let cgImage = UIGraphicsGetImageFromCurrentImageContext()?.cgImage,
              let dataProvider = cgImage.dataProvider,
              let data = dataProvider.data else {
            UIGraphicsEndImageContext()
            return nil
        }
        UIGraphicsEndImageContext()
        
      guard let ptr = CFDataGetBytePtr(data) else {
          UIGraphicsEndImageContext()
          return nil
      }

      let bytesPerPixel = 4
      var hash: UInt64 = 0
      var bitIndex = 0

      for row in 0..<8 {
          for col in 0..<8 {
              // Тепер ptr гарантовано не nil, і ми можемо використовувати сабскрипт []
              let offsetLeft = (row * Int(size.width) + col) * bytesPerPixel
              let offsetRight = (row * Int(size.width) + (col + 1)) * bytesPerPixel
              
              let leftGray = (Int(ptr[offsetLeft]) + Int(ptr[offsetLeft + 1]) + Int(ptr[offsetLeft + 2])) / 3
              let rightGray = (Int(ptr[offsetRight]) + Int(ptr[offsetRight + 1]) + Int(ptr[offsetRight + 2])) / 3
              
              if leftGray > rightGray {
                  hash |= (1 << bitIndex)
              }
              bitIndex += 1
          }
      }
        return hash
    }
}
