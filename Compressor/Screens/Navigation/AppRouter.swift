//
//  AppRouter.swift
//  Compressor
//
//  Created by Vlad Sadovnyk on 01.03.2026.
//  Copyright © 2026 Vlad Sadovnyk. All rights reserved.
//
//  Licensed under the MIT License. See LICENSE file in the project root for full license information.
//

import SwiftUI


struct AppRouter: View {
  @AppStorage("OnBoarding") var onBoarding: Bool = true
  var body: some View {
    VStack{
      if onBoarding{
        OnBoardingView()
      }else{
        MainView()
      }
    }
    .animation(.easeOut, value: onBoarding)
  }
}

#Preview {
    AppRouter()
}
