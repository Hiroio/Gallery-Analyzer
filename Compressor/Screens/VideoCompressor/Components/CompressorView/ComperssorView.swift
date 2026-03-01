//
//  ComperssorView.swift
//  Compressor
//
//  Created by Vlad Sadovnyk on 02.03.2026.
//  Copyright © 2026 Vlad Sadovnyk. All rights reserved.
//
//  Licensed under the MIT License. See LICENSE file in the project root for full license information.
//

import SwiftUI
import AVKit

struct ComperssorView: View {
  @EnvironmentObject private var vm: VideoCompressorViewModel
  @State private var slideAnimation: Bool = true
  let item: MediaFile
  var body: some View {
    ZStack{
      vm.screenState == .loading ? (Color.background.ignoresSafeArea()) : Color.clear.ignoresSafeArea()
      
      switch vm.screenState {
      case .selection:
        SelectionMenu(item: item, slideAnimation: $slideAnimation)
          .onAppear{
            withAnimation(.easeInOut(duration: 0.8)){
              slideAnimation = true
            }
          }
      case .loading:
        VStack{
          LoadingScreen(progress: vm.compressionProgress)
          
        }
        .padding()
        .animation(.easeInOut(duration: 1), value: vm.screenState)
      case .result:
        CompressionResultView(item: item)
      }
    }
    .animation(.easeInOut(duration: 1), value: vm.screenState)
  }
}

#Preview {
  VideoCompressorView()
}


//MARK: INFO About compressing
struct InfoAboutCompress: View{
  let fileSize: Double
  let compressSize: Double
  let compresion: Bool
  var body: some View{
    HStack{
      VStack{
        Text(compresion ? "Old size" : "Now")
        Text("\(fileSize, specifier: "%.2f")MB")
          .font(.title)
          .foregroundStyle(.black)
      }
      Spacer()
      HStack(spacing: 3){
        Image(systemName: "chevron.forward")
          .opacity(0.5)
        Image(systemName: "chevron.forward")
      }
      .foregroundStyle(.accent)
      .font(.title2)
      
      Spacer()
      
      VStack{
        Text(compresion ? "Now" : "Will be")
        Text("\(compressSize, specifier: "%.2f")MB")
          .font(.title)
          .foregroundStyle(.accent)
          .contentTransition(.numericText())
      }
    }
    .padding(.horizontal)
    .foregroundStyle(.gray)
  }
}

struct OptionSelection: View{
  @Binding var selectedOption: CompressOptions
  var body: some View{
    VStack(spacing: 20){
      ForEach(CompressOptions.allCases){item in
        Button{
          withAnimation(){
            selectedOption = item
          }
        }label:{
          HStack{
            Text(item.text)
              .font(.title3)
            Spacer()
            Image(systemName: selectedOption == item ? "checkmark.circle.fill" : "circle")
              .font(.title)
            
          }
          .foregroundStyle(.accent)
          .padding(12)
          .background(
            RoundedRectangle(cornerRadius: 15)
              .fill(.white)
              .shadow(radius: 2)
          )
        }
      }
    }
  }
}


