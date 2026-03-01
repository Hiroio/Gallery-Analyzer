//
//  MediaDashBoardView.swift
//  Compressor
//
//  Created by Vlad Sadovnyk on 01.03.2026.
//  Copyright © 2026 Vlad Sadovnyk. All rights reserved.
//
//  Licensed under the MIT License. See LICENSE file in the project root for full license information.
//

import SwiftUI

struct MediaDashBoardView: View {
  @AppStorage("isAuthorized") var isAuthorized: Bool = false
  @StateObject var vm: MediaDashBoardViewModel = .init()
  @State private var animate = false
    var body: some View {
      VStack{
        Text("Media")
          .frame(maxWidth: .infinity, alignment: .leading)
          .font(.title)
          .fontWeight(.medium)
          .padding(.horizontal)
        ScrollView{
          LazyVGrid(columns: Array(repeating: .init(.flexible(minimum: 150, maximum: 250)), count: 2), spacing: 15){
            ForEach(MediaDashBoard.allCases){item in
              NavigationLink {
                  Group {
                      switch item {
                      case .similarVideo, .similarPhoto, .duplicatePhoto:
                          ForDictionaryDashBoard(item: item)
                              .environmentObject(vm)
                      case .livephoto, .screenshots, .screenRecording:
                          ForSingleDashBoard(item: item)
                              .environmentObject(vm)
                      }
                  }
              }label:{
                CardLabel(item: item, count: vm.getCount(item))
              }
              .disabled(!isAuthorized)
            }
          }
          .padding()
        }
        if !isAuthorized{
          VStack{
            Circle()
              .frame(width: animate ? 10 : 20)
            
            Text("No library access")
            
            if let url = URL(string: UIApplication.openSettingsURLString) {
              Link("Change Access", destination: url)
                .padding(10)
                .foregroundStyle(.white)
                .background(
                  RoundedRectangle(cornerRadius: 10)
                    .fill(.accent)
                )
            }

          }
          .foregroundStyle(.accent)
        }
        }
      .onAppear(){
        if !isAuthorized{
          withAnimation(.easeOut(duration: 1).repeatForever()){
            animate.toggle()
          }
        }
      }
    }
}

#Preview {
    MediaDashBoardView()
}

@ViewBuilder
func CardLabel(item: MediaDashBoard, count: Int) -> some View{
    VStack(alignment: .leading){
      Image(systemName: item.icon)
        .frame(width: 20, height: 20)
        .foregroundStyle(.accent)
        .padding(10)
        .background(
          Circle()
            .fill(.accent.opacity(0.4))
        )
        .frame(maxWidth: .infinity, alignment: .leading)
      
      Text(item.text)
        .font(.headline)
        .fixedSize()
      Text("\(count) Items")
        .foregroundStyle(.gray)
        .contentTransition(.numericText())
    }
    .padding(10)
    .background(
      RoundedRectangle(cornerRadius: 15)
        .fill(.white)
        .shadow(radius: 2)
    )
}
