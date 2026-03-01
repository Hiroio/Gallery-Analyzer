//
//  PieChart.swift
//  Compressor
//
//  Created by Vlad Sadovnyk on 01.03.2026.
//  Copyright © 2026 Vlad Sadovnyk. All rights reserved.
//
//  Licensed under the MIT License. See LICENSE file in the project root for full license information.
//

import SwiftUI

struct PieChart: View {
  @Binding var targetProgress: Double
  @State private var animationProgress: Double = 0.0
  var body: some View {
    ZStack(alignment: .bottom){
      Circle()
        .stroke(Color.white.opacity(0.2), lineWidth: 15)
        .shadow(color: Color.accent, radius: 5)
      Circle()
        .trim(from: 0, to: animationProgress)
        .stroke(
          Color.accent,
          style: StrokeStyle(lineWidth: 15, lineCap: .round)
        )
        .rotationEffect(.degrees(-90))

    }
    .overlay(
      VStack {
        Text("\(Int(animationProgress * 100))%")
          .font(.title.bold())
          .contentTransition(.numericText())
        Text("used")
          .font(.caption)
      }
    )
    .onChange(of: targetProgress) { newValue in
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
          withAnimation(.easeInOut(duration: 1)) {
          self.animationProgress = newValue
        }
      }
    }
  }
}

#Preview {
  MainView()
}
