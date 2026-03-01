//
//  GridItem.swift
//  Compressor
//
//  Created by Vlad Sadovnyk on 01.03.2026.
//  Copyright © 2026 Vlad Sadovnyk. All rights reserved.
//
//  Licensed under the MIT License. See LICENSE file in the project root for full license information.
//

import SwiftUI
import Photos

struct GridItem: View {
  let file: MediaFile
  let isSelected: Bool
  let isBest: Bool
  
  @State private var thumbnail: UIImage?
  
  var body: some View {
    ZStack(alignment: .bottom) {
      Group {
        if let image = thumbnail {
          Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fill)
        } else {
          Rectangle()
            .fill(Color.gray.opacity(0.2))
            .overlay(ProgressView().scaleEffect(0.8))
        }
      }
      .frame(width: (UIScreen.main.bounds.width / 2) - 20, height: 180)
      .clipShape(RoundedRectangle(cornerRadius: 12))
      .contentShape(Rectangle())
      
      HStack(spacing: 0){
        if isBest{
          HStack{
            Image(systemName: "sparkles")
            Text("Best")
          }
          .padding(10)
          .background(
            RoundedRectangle(cornerRadius: 10)
              .fill(.white)
              .shadow(radius: 2)
          )
        }
        Spacer()
        Image(systemName: isSelected ? "checkmark.square.fill" : "square")
          .foregroundStyle(isSelected ? .accent : .white)
          .font(.title2)
          .padding(8)
          .shadow(radius: 2)
      }
    }
    .onAppear {
      loadThumbnail()
    }
  }
  
  private func loadThumbnail() {
    let manager = PHImageManager.default()
    let options = PHImageRequestOptions()
    options.deliveryMode = .opportunistic
    options.isNetworkAccessAllowed = false
    
    manager.requestImage(for: file.asset,
                         targetSize: CGSize(width: 300, height: 300),
                         contentMode: .aspectFill,
                         options: options) { image, _ in
      self.thumbnail = image
    }
  }
}
