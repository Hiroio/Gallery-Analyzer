//
//  VideoComponent.swift
//  Compressor
//
//  Created by Vlad Sadovnyk on 01.03.2026.
//  Copyright © 2026 Vlad Sadovnyk. All rights reserved.
//
//  Licensed under the MIT License. See LICENSE file in the project root for full license information.
//

import SwiftUI
import Photos

struct VideoComponent: View {
  let item: MediaFile
  @State private var image: UIImage? = nil
  var body: some View {
    let width = UIScreen.main.bounds.width / 2.2
    VStack{
      if let image{
        Image(uiImage: image)
          .resizable()
          .scaledToFill()
          .frame(width: width, height: width)
          .clipped()
      }else{
        Rectangle()
          .foregroundStyle(.gray)
          .overlay(
            ProgressView()
          )
      }
    }
    .frame(width: width, height: width)
    .overlay(
      Text("\(item.fileSize.toDoubleMB().formatted(.number.precision(.fractionLength(1)))) MB")
        .foregroundStyle(.white)
        .padding(5)
        .background(
          RoundedRectangle(cornerRadius: 10)
            .fill(.accent)
        )
        .padding(8),
      alignment: .topLeading
    )
    .cornerRadius(20)
    .shadow(radius: 2)
    .onAppear{
      Task{
        loadThumbnail(asset: item.asset)
      }
    }
  }
  private func loadThumbnail(asset: PHAsset) {
      let manager = PHImageManager.default()
      let options = PHImageRequestOptions()
      
    options.deliveryMode = .highQualityFormat
      
      options.isNetworkAccessAllowed = false
    options.resizeMode = .exact

      manager.requestImage(for: asset,
                           targetSize: CGSize(width: 300, height: 300),
                           contentMode: .aspectFill,
                           options: options) { result, info in
          
          if let result = result {
              DispatchQueue.main.async {
                  self.image = result
              }
          } else {
              DispatchQueue.main.async {
                  self.image = UIImage(systemName: "video.fill")
              }
          }
      }
  }
}

#Preview {
  VideoCompressorView()
}
