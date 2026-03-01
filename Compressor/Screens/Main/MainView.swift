//
//  MainView.swift
//  Compressor
//
//  Created by Vlad Sadovnyk on 01.03.2026.
//  Copyright © 2026 Vlad Sadovnyk. All rights reserved.
//
//  Licensed under the MIT License. See LICENSE file in the project root for full license information.
//

import SwiftUI
import Combine


struct MainView: View {
  @StateObject var vm = MainViewModel.shared
  var body: some View {
    NavigationStack{
      ZStack{
        Color.background.ignoresSafeArea()
        VStack(spacing: 30){
          MainHeader()
            .padding()
          
          WorkAreaView()
            .frame(maxHeight: .infinity)
            .padding(.bottom)
            .background(
              UnevenRoundedRectangle(cornerRadii: .init(topLeading: 20, bottomLeading: 0, bottomTrailing: 0, topTrailing: 20))
                .fill(.white)
            )
            .ignoresSafeArea(edges: .bottom)
            .environmentObject(vm)
        }
        
      }
    }
  }
}

#Preview {
    MainView()
}
