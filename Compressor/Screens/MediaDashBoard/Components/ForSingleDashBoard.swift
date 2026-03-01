//
//  ForSingleDashBoard.swift
//  Compressor
//
//  Created by Vlad Sadovnyk on 01.03.2026.
//  Copyright © 2026 Vlad Sadovnyk. All rights reserved.
//
//  Licensed under the MIT License. See LICENSE file in the project root for full license information.
//

import SwiftUI

struct ForSingleDashBoard: View {
  @EnvironmentObject var vm: MediaDashBoardViewModel
  @State private var selectedItems: [MediaFile] = []
  private var array: [MediaFile] {
    switch item {
    case .screenshots:
      vm.screenshots
    case .livephoto:
      vm.livePhotos
    case .screenRecording:
      vm.screenshots
    default:
      []
    }
  }
  let item: MediaDashBoard
    var body: some View {
      VStack{
        InfoHeader(size: size, amount: array.count, item: item)
        VStack{
          if array.isEmpty{
            VStack(spacing: 25){
            Text("Not Found")
            Image(systemName: "xmark.bin")
          }
            .font(.title.bold())
            .foregroundStyle(.accent)
          }else{
            ScrollView{
              LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 2)){
                ForEach(array) { item in
                  GridItem(file: item, isSelected: selectedItems.contains(where: {$0.id == item.id}), isBest: false)
                    .onTapGesture {
                      withAnimation(){
                        handleSelect(item: item)
                      }
                    }
                }
              }
            }
          }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(
          Group{
            if !selectedItems.isEmpty{
              Button{
                withAnimation(){
                  vm.deleteSelectedItems(items: selectedItems, category: item)
                  selectedItems.removeAll()
                }
              }label:{
                Text("Delete \(selectedItems.count) \(item.element) (\(selectedSize, specifier: "%.1f") MB)")
                  .font(.title3)
                  .foregroundStyle(.white)
                  .frame(maxWidth: .infinity)
                  .padding()
                  .background(
                    RoundedRectangle(cornerRadius: 15)
                      .fill(.accent)
                  )
              }
              .transition(.opacity)
              .allowsHitTesting(!selectedItems.isEmpty)
            }
          },
          alignment: .bottom
        )
        
      }
      .padding()
      .animation(.easeInOut, value: array.count)
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button{
            withAnimation(.easeInOut(duration: 0.4)){
              if selectedItems.isEmpty{
                selectedItems = array
              }else{
                selectedItems.removeAll()
              }
            }
          }label:{
            Text(selectedItems.isEmpty ? "Select All" : "Deselect All")
          }
        }
      }
    }

  
  private var selectedSize: Double{
    selectedItems.reduce(0.0) { result, number in
      result + number.fileSize.toDoubleMB()
    }
  }
  private var size: Double{
    array.reduce(0.0) { result, number in
      result + number.fileSize.toDoubleMB()
    }
  }
  
  func handleSelect(item: MediaFile){
    if selectedItems.contains(where: {$0.id == item.id}){
      selectedItems.removeAll(where: {$0.id == item.id})
    }else{
      selectedItems.append(item)
    }
  }
}

#Preview {
  NavigationStack{
    ForSingleDashBoard(item: .screenshots)
  }
}
