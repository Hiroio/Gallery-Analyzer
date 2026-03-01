//
//  VideoCompressor.swift
//  Compressor
//
//  Created by Vlad Sadovnyk on 01.03.2026.
//  Copyright © 2026 Vlad Sadovnyk. All rights reserved.
//
//  Licensed under the MIT License. See LICENSE file in the project root for full license information.
//

import SwiftUI

struct VideoCompressor: View {
  @EnvironmentObject var vm: MainViewModel
  
  @AppStorage("Videos") var videos: Int = 0
  @AppStorage("VideosSize") var videosSize: Double = 0.0
    var body: some View {
      VStack{
        HStack(spacing: 20){
          
          Image(systemName: "video.fill")
            .font(.caption)
            .padding(5)
            .padding(.vertical, 5)
            .foregroundStyle(.pink)
            .background(
              RoundedRectangle(cornerRadius: 5)
                .fill(.pink.opacity(0.2))
            )
          
          Text("Video Compressor")
            .font(.title)
            .foregroundStyle(.primary)
            .fontWeight(.medium)
          
          Spacer()
          
          if !vm.isAuthorized{
            Image(systemName: "lock.fill")
              .foregroundStyle(.red)
              .padding(8)
              .background(
                Circle()
                  .fill(.red.opacity(0.2))
              )
          }
        }
        Text("\(vm.videosCount ?? 0) Media • \(vm.videoSize ?? 0, specifier: "%.1f") GB")
          .contentTransition(.numericText())
          .foregroundStyle(.gray)
          .frame(maxWidth: .infinity, alignment: .leading)
        
        let heigt = UIScreen.main.bounds.width / 1.5
        Image("videoCompressor")
          .resizable()
          .frame(maxHeight: heigt)
          .scaledToFit()
          .cornerRadius(20)
      }
      .animation(.linear, value: vm.videosCount)
      .padding()
    }
}

#Preview {
    VideoCompressor()
    .environmentObject(MainViewModel())
}
