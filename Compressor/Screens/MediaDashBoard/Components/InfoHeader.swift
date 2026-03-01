//
//  InfoHeader.swift
//  Compressor
//
//  Created by Vlad Sadovnyk on 01.03.2026.
//  Copyright © 2026 Vlad Sadovnyk. All rights reserved.
//
//  Licensed under the MIT License. See LICENSE file in the project root for full license information.
//

import SwiftUI

struct InfoHeader: View {
  let size: Double
  let amount: Int
  let item: MediaDashBoard
  var body: some View {
    VStack{
      Text(item.text)
        .font(.title2)
        .fontWeight(.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
      
      HStack{
        HStack{
          Image(systemName: item.icon)
          Text("\(amount)")
        }
        .padding(8)
        .background(
          RoundedRectangle(cornerRadius: 10)
            .fill(.white)
            .shadow(radius: 1)
        )
        
        HStack{
          Image(systemName: "archivebox.fill")
          if size > 1000{
            Text("\(size, specifier: "%.1f") MB")
          }else{
            Text("\(size/1000, specifier: "%.1f") GB")
          }
        }
        .padding(8)
        .background(
          RoundedRectangle(cornerRadius: 10)
            .fill(.white)
            .shadow(radius: 1)
        )
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
  }
}

#Preview {
  InfoHeader(size: 0, amount: 0, item: .duplicatePhoto)
}
