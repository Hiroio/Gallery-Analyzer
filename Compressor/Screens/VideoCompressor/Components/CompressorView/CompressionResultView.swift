//
//  CompressionResultView.swift
//  Compressor
//
//  Created by Vlad Sadovnyk on 02.03.2026.
//  Copyright © 2026 Vlad Sadovnyk. All rights reserved.
//
//  Licensed under the MIT License. See LICENSE file in the project root for full license information.
//

import SwiftUI
import AVKit

struct CompressionResultView: View {
  @Environment(\.dismiss) var dismiss
  @EnvironmentObject var vm: VideoCompressorViewModel
  @State private var animate: Bool = false
  let item: MediaFile
    var body: some View {
      VStack(spacing: 20){
        if animate{
          Text("Video Compressor")
            .font(.title2)
            .fontWeight(.medium)
            .frame(maxWidth: .infinity, alignment: .leading)
            .transition(.move(edge: .top))
          
          Spacer()
          
          VStack(spacing: 15){
            if let player = vm.player{
              VideoPlayer(player: player)
            }else{
              Rectangle()
            }
            InfoAboutCompress(fileSize: item.fileSize.toDoubleMB(), compressSize: vm.compressedSize, compresion: true)
          }
          .frame(maxHeight: .infinity)
          .transition(.opacity)
          
          Spacer()
          VStack{
            Button{
              Task{
                await vm.finalizeCompression(deleteOriginal: true, item: item)
                vm.screenState = .selection
                dismiss()
              }
            }label: {
              Text("Delete Original Video")
                .foregroundStyle(.accent)
            }
            Button{
              Task{
                await vm.finalizeCompression(deleteOriginal: false, item: item)
                vm.screenState = .selection
                dismiss()
              }
            }label:{
              Text("Keep Original Video")
                .frame(maxWidth: .infinity)
                .foregroundStyle(.white)
                .padding()
                .padding(.vertical, 5)
                .background(
                  RoundedRectangle(cornerRadius: 15)
                    .fill(.accent)
                )
            }
            
          }
          .transition(.move(edge: .bottom))
        }
      }
      .onAppear(){
        withAnimation(.easeInOut(duration: 0.8)){
          animate = true
        }
      }
      .padding()
    }
}

#Preview {
  VideoCompressorView()
}
