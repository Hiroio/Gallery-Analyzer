//
//  VideoCompressorView.swift
//  Compressor
//
//  Created by Vlad Sadovnyk on 01.03.2026.
//  Copyright © 2026 Vlad Sadovnyk. All rights reserved.
//
//  Licensed under the MIT License. See LICENSE file in the project root for full license information.
//

import SwiftUI

struct VideoCompressorView: View {
  @AppStorage("isAuthorized") var isAuthorized: Bool = false
  @StateObject private var vm = VideoCompressorViewModel()
  @State private var videos: [MediaFile] = []
  @State private var animate = false
  var body: some View {
    VStack{
      VStack(alignment: .leading, spacing: 5){
        Text("Video Compressor")
          .font(.title2)
          .fontWeight(.medium)
        HStack{
          Image(systemName: "video.fill")
          Text("\(vm.videos.count) Videos")
            .font(.caption)
            .foregroundStyle(.gray)
        }
        .padding(8)
        .background(
          RoundedRectangle(cornerRadius: 5)
            .fill(.white)
            .shadow(radius: 2)
        )
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding()
      ScrollView{
        LazyVGrid(columns: Array(repeating: .init(.flexible(maximum: 200)), count: 2)){
          ForEach(vm.videos){item in
            NavigationLink{
              ComperssorView(item: item)
                .environmentObject(vm)
            }label:{
              VideoComponent(item: item)
                .environmentObject(vm)
            }
          }
        }
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
    VideoCompressorView()
}
