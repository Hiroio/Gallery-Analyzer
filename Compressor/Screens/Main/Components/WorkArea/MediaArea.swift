//
//  MediaArea.swift
//  Compressor
//
//  Created by Vlad Sadovnyk on 01.03.2026.
//  Copyright © 2026 Vlad Sadovnyk. All rights reserved.
//
//  Licensed under the MIT License. See LICENSE file in the project root for full license information.
//

import SwiftUI

struct MediaArea: View {
  @EnvironmentObject var vm: MainViewModel
  @AppStorage("Photos") var photos: Int = 0
  @AppStorage("PhotosSize") var photosSize: Double = 0.0
    var body: some View {
      VStack{
        HStack(spacing: 20){
          Image(systemName: "photo.fill")
            .padding(2)
            .padding(.vertical, 5)
            .foregroundStyle(.accent)
            .background(
              RoundedRectangle(cornerRadius: 5)
                .fill(.blue.opacity(0.2))
            )
          Text("Media")
            .font(.title)
            .fontWeight(.medium)
            .foregroundStyle(.primary)
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
        HStack{
          Text("\(vm.mediaCount ?? 0)")
            .contentTransition(.numericText())
          Text("Media •")
          Text("\(vm.mediaSize ?? 0, specifier: "%.1f")")
              .contentTransition(.numericText())
          Text("GB")
          
          Spacer()
          HStack{
            Text("View all")
            Image(systemName: "chevron.forward")
              .font(.caption)
            
          }
        }
        .animation(.linear, value: vm.mediaSize)
        .foregroundStyle(.gray)
        
        
        HStack(spacing: 15){
          let height = UIScreen.main.bounds.width / 2.3
          Image("firstMedia")
            .resizable()
            .scaledToFill()
            .frame(height: height)
            .cornerRadius(20)
          
          Image("secondMedia")
            .resizable()
            .scaledToFill()
            .frame(height: height)
            .clipped()
            .cornerRadius(20)
            
        }
        .frame(maxWidth: .infinity)
        
        
      }
      .padding()
    }
}

#Preview {
  MediaArea()
    .environmentObject(MainViewModel())
}
