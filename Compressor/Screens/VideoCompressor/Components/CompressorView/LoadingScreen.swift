//
//  LoadingScreen.swift
//  Compressor
//
//  Created by Vlad Sadovnyk on 02.03.2026.
//  Copyright © 2026 Vlad Sadovnyk. All rights reserved.
//
//  Licensed under the MIT License. See LICENSE file in the project root for full license information.
//

import SwiftUI

struct LoadingScreen: View {
  @Environment(\.dismiss) var dismiss
  @EnvironmentObject var vm: VideoCompressorViewModel
  let progress: Double
    var body: some View {
      VStack{
        Spacer()
        ProgressView()
        VStack{
          Text("\(Int(progress * 100))%")
            .contentTransition(.numericText())
          Text("Compessing Video ...")
        }
        .font(.title2)
        Spacer()
        Text("Please don’t close the app in order not to lose all progress")
          .font(.caption)
        Button("Cancel"){
          withAnimation(){
            vm.cancel()
            dismiss()
          }
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
      .foregroundStyle(.white)
      .multilineTextAlignment(.center)
    }
}

#Preview {
  LoadingScreen(progress:0)
}
