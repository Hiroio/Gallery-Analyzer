//
//  ForDictionaryDashBoard.swift
//  Compressor
//
//  Created by Vlad Sadovnyk on 01.03.2026.
//  Copyright © 2026 Vlad Sadovnyk. All rights reserved.
//
//  Licensed under the MIT License. See LICENSE file in the project root for full license information.
//

import SwiftUI
import Photos

struct ForDictionaryDashBoard: View {
  @EnvironmentObject var vm: MediaDashBoardViewModel
  @State private var selectedItems: [MediaFile] = []
  @State private var animate = false
  private var dictionary: [String: [MediaFile]] {
          switch item {
          case .duplicatePhoto:
              return vm.exactDuplicatesGrouped
          case .similarPhoto:
              return vm.similarImages
          case .similarVideo:
              return vm.similarVideos
          default:
              return [:]
          }
      }
  let item: MediaDashBoard
  var body: some View {
    VStack {
      InfoHeader(size: size, amount: dictionary.count, item: item)
      if dictionary.isEmpty{
        VStack(spacing: 25){
          if vm.videosIsLoading{
            VStack{
              Spacer()
              HStack{
                  Circle()
                    .frame(width: animate ? 70 : 80)
                    .offset(x: animate ? 50 : 20)
                Circle()
                    .frame(width: animate ? 70 : 80)
                    .offset(x: animate ? -50 : -20)
              }
                .onAppear(){
                  withAnimation(.easeInOut(duration: 1).repeatForever()){
                    animate.toggle()
                  }
                }
              Spacer()
              Text("Searching for similar Videos...")
                .font(.caption)
                .foregroundStyle(.accent)
              Spacer()
            }
          }else{
            Text("Not Found")
            Image(systemName: "xmark.bin")
          }
        }
        .font(.title.bold())
        .foregroundStyle(.accent)
      }else{
        ScrollView {
          LazyVStack(spacing: 25) {
            ForEach(Array(dictionary.keys), id: \.self) { key in
              if let files = dictionary[key] {
                groupSection(key: key, files: files)
              }
            }
          }.drawingGroup()
        }
      }
    }
    .onAppear(){
      if item == .similarVideo{
        vm.getSimilarVideos()
      }
    }
    .animation(.easeInOut, value: dictionary.count)
    .frame(maxWidth: .infinity)
    .padding()
    .overlay(deleteButtonOverlay, alignment: .bottom)
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button(selectedItems.isEmpty ? "Select All" : "Deselect All") {
          toggleAllItems()
        }
      }
    }
  }
  
  @ViewBuilder
  private func groupSection(key: String, files: [MediaFile]) -> some View {
    let isGroupSelected = checkGroupSelection(files: files)
    
    VStack(alignment: .leading, spacing: 10) {
      HStack {
        Text("\(files.count) \(item.element)")
          .font(.headline)
        Spacer()
        Button(isGroupSelected ? "Deselect all" : "Select all") {
          handleGroup(item: files, isFullSelected: isGroupSelected)
        }
        .foregroundStyle(.gray)
        .font(.subheadline)
      }
      
      let bestPhoto = files.max(by: { f1, f2 in
          let pixels1 = f1.asset.pixelWidth * f1.asset.pixelHeight
          let pixels2 = f2.asset.pixelWidth * f2.asset.pixelHeight
          
          if pixels1 == pixels2 {
              return f1.fileSize < f2.fileSize
          }
          return pixels1 < pixels2
      })
      LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 10), count: 2), spacing: 10) {
        ForEach(files) { file in
          let bestPhotoID = bestPhoto?.id
          GridItem(file: file, isSelected: isItemSelected(file), isBest: file.id == bestPhotoID)
            .onTapGesture {
              withAnimation(.spring(response: 0.3)) {
                handleSelect(item: file)
              }
            }
        }
      }
    }
  }
  
  // MARK: - Helper Methods FOR Btn
  private func isItemSelected(_ file: MediaFile) -> Bool {
    selectedItems.contains(where: { $0.id == file.id })
  }
  
  private func checkGroupSelection(files: [MediaFile]) -> Bool {
    files.contains(where: { isItemSelected($0) })
  }
  
  func handleSelect(item: MediaFile) {
    if let index = selectedItems.firstIndex(where: { $0.id == item.id }) {
      selectedItems.remove(at: index)
    } else {
      selectedItems.append(item)
    }
  }
  
  func handleGroup(item: [MediaFile], isFullSelected: Bool) {
    if isFullSelected {
      let idsToRemove = Set(item.map { $0.id })
      selectedItems.removeAll(where: { idsToRemove.contains($0.id) })
    } else {
      let currentIDs = Set(selectedItems.map { $0.id })
      let newItems = item.filter { !currentIDs.contains($0.id) }
      selectedItems.append(contentsOf: newItems)
    }
  }
  
  private func toggleAllItems() {
    withAnimation {
      if selectedItems.isEmpty {
        selectedItems = dictionary.values.flatMap { $0 }
      } else {
        selectedItems.removeAll()
      }
    }
  }
  
//  MARK: Utilities
  private var selectedSize: Double {
    selectedItems.reduce(0.0) { $0 + $1.fileSize.toDoubleMB() }
  }
  
  private var size: Double {
    dictionary.values.flatMap { $0 }.reduce(0.0) { $0 + $1.fileSize.toDoubleMB() }
  }
  
//MARK:  Overlay BTN
  private var deleteButtonOverlay: some View {
    Group {
      if !selectedItems.isEmpty {
        Button{
          withAnimation(){
            vm.deleteSelectedItems(items: selectedItems, category: item)
            selectedItems.removeAll()
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5){
            }
          }
        }label: {
          Text("Delete \(selectedItems.count) \(item.element) (\(selectedSize, specifier: "%.1f") MB)")
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(RoundedRectangle(cornerRadius: 15).fill(Color.accentColor))
            .padding(.horizontal)
        }
        .padding(.bottom, 10)
      }
    }
  }
}

#Preview {
  ForDictionaryDashBoard(item: .similarPhoto)
}
