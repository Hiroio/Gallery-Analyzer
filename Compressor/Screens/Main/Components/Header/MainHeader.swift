//
//  MainHeader.swift
//  Compressor
//
//  Created by Vlad Sadovnyk on 01.03.2026.
//  Copyright © 2026 Vlad Sadovnyk. All rights reserved.
//
//  Licensed under the MIT License. See LICENSE file in the project root for full license information.
//

import SwiftUI

struct MainHeader: View {
  @State private var storage = StorageInfo(total: 0, used: 0, ratio: 0)
  var body: some View {
    HStack{
      VStack(alignment: .leading){
        Text("iPhone Storage")
        HStack{
          Text("\(storage.usedGB, specifier: "%.1f") GB")
            .font(.headline)
            .contentTransition(.numericText())
          Text("of \(storage.totalGB, specifier: "%.1f") GB")
            .contentTransition(.numericText())
        }
        .fixedSize()
      }
      .frame(maxWidth: .infinity)
      
      PieChart(targetProgress: $storage.ratio)
        .frame(maxWidth: .infinity)
        .padding()
      
    }
    .onAppear{
      let storage = storage.update()
        self.storage = storage
    }
    .padding(.horizontal)
    .foregroundStyle(.white)
  }
}

#Preview {
  MainView()
}
