//
//  SelectionMenu.swift
//  Compressor
//
//  Created by Vlad Sadovnyk on 01.03.2026.
//  Copyright © 2026 Vlad Sadovnyk. All rights reserved.
//
//  Licensed under the MIT License. See LICENSE file in the project root for full license information.
//

import SwiftUI
import AVKit

struct SelectionMenu: View {
  let item: MediaFile
  @EnvironmentObject private var vm: VideoCompressorViewModel
  @Binding var slideAnimation: Bool
    var body: some View {
      VStack{
        if slideAnimation{
          Text("Video Compressor")
            .font(.title2)
            .fontWeight(.medium)
            .frame(maxWidth: .infinity, alignment: .leading)
            .transition(.move(edge: .top))
        }
        if slideAnimation{
          Spacer()
          VStack(spacing: 15){
            if let player = vm.player {
              VideoPlayer(player: player)
                .frame(height: 250)
                .cornerRadius(20)
                .padding(.vertical)
            }
            let itemSize = item.fileSize.toDoubleMB()
            InfoAboutCompress(fileSize: itemSize, compressSize: vm.calculateWillBeSize(for: itemSize, option: vm.selectedOption), compresion: false)
          }
          .transition(.opacity)
          Spacer()
        }
        if slideAnimation{
          VStack{
            OptionSelection(selectedOption: $vm.selectedOption)
            compressBtn
          }
          .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom)))
        }
      }
      .animation(.linear, value: slideAnimation)
      .zIndex(1)
      .padding()
      .onAppear{
        vm.setupPlayerForAsset(item.asset)
      }
      .onDisappear {
        vm.player?.pause()
      }
    }
  
  private var compressBtn: some View{
    Button{
      withAnimation(.easeInOut(duration: 0.6)) {
        slideAnimation = false
      }
      
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        withAnimation { vm.screenState = .loading }
        
        Task {
          await vm.startCompression(for: item, quality: vm.selectedOption)
        }
      }
    }label:{
      HStack{
        Image(systemName: "arrow.down.forward.and.arrow.up.backward")
        Text("Compress")
      }
      .foregroundStyle(.white)
      .padding()
      .padding(.vertical, 5)
      .frame(maxWidth: .infinity)
      .background(
        RoundedRectangle(cornerRadius: 15)
          .fill(.accent)
      )
    }
  }
}

#Preview {
    VideoCompressorView()
}
