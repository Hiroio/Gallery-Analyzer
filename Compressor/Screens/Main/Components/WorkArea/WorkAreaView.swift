//
//  WorkAreaView.swift
//  Compressor
//
//  Created by Vlad Sadovnyk on 01.03.2026.
//  Copyright © 2026 Vlad Sadovnyk. All rights reserved.
//
//  Licensed under the MIT License. See LICENSE file in the project root for full license information.
//

import SwiftUI

struct WorkAreaView: View {
    var body: some View {
      VStack{
        NavigationLink{
          VideoCompressorView()
        }label:{
          VideoCompressor()
        }
        NavigationLink{
          MediaDashBoardView()
        }label:{
          MediaArea()
        }
      }
    }
}

#Preview {
    MainView()
}
