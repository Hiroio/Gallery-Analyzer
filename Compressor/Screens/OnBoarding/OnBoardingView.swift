//
//  OnBoardingView.swift
//  Compressor
//
//  Created by Vlad Sadovnyk on 01.03.2026.
//  Copyright © 2026 Vlad Sadovnyk. All rights reserved.
//
//  Licensed under the MIT License. See LICENSE file in the project root for full license information.
//

import SwiftUI

struct OnBoardingView: View {
  @AppStorage("OnBoarding") var onBoarding: Bool = true
  @State private var selection: Int = 0
    var body: some View {
      VStack{
        
        TabView(selection: $selection){
          OnBoardingComponents(
            title: "Clean your Storage",
            description: "Pick the best & delete the rest",
            image: Image("firstOnBoarding"))
          .tag(0)
          
          OnBoardingComponents(
            title: "Detect Similar Photos",
            description: "Clean similar photos & videos, save your storage space on your phone.",
            image:
              Image("secondOnBoarding")
              .overlay(
                Image("secondOnBoardingComponent")
                  .resizable()
                  .scaledToFit()
                  .scaleEffect(1.2)
                ,
                alignment: .bottom
              )
            
          )
          .tag(1)
          OnBoardingComponents(
            title: "Video Compressor",
            description: "Find large videos or media files and compress them to free up storage space",
            image: Image("thirdOnBoarding"))
          .tag(2)
          
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
      }
      Spacer()
      VStack(spacing: 20){
        HStack{
          ForEach(0..<3){ i in
            let match = selection == i
            RoundedRectangle(cornerRadius: 50)
              .fill(match ? .blue : .gray)
              .frame(width: match ? 16 : 8, height: 8)
          }
        }
        .animation(.linear, value: selection)
        
        Button{
          withAnimation(){
            selection == 2 ? (onBoarding = false) : (selection += 1)
          }
        }label:{
          Text("Continue")
            .frame(maxWidth: .infinity)
            .foregroundStyle(.white)
            .padding(20)
            .background(
              RoundedRectangle(cornerRadius: 10)
                .fill(.blue)
            )
            .padding(.horizontal)
        }
      }
    }
}

@ViewBuilder
func OnBoardingComponents(title: String, description: String, image: some View) -> some View{
  VStack(spacing: 20){
    image
      
    Ellipse()
      .fill(.black)
      .frame(width: 230, height: 5)
      .opacity(0.3)
      .blur(radius: 3)
    
    VStack{
      Text(title)
        .font(.title)
      Text(description)
        .foregroundStyle(.gray)
    }
    .multilineTextAlignment(.center)
    .padding(.horizontal)
  }
}

#Preview {
  OnBoardingView()
}
