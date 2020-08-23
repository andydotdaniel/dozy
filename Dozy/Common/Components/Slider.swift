//
//  Slider.swift
//  Dozy
//
//  Created by Andrew Daniel on 8/23/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import SwiftUI

struct Slider: View {
    
    @State private var controlWidthOffset: CGFloat = .zero
    let titleText: String
    
    private let horizontalPadding: CGFloat = 16
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                Text(self.titleText)
                    .foregroundColor(Color.borderGray)
                    .bold()
                    .font(.headline)
                    .offset(x: 18)
            }
            .frame(height: 44)
            .frame(maxWidth: .infinity)
            .padding(8)
            .background(Color.white)
            .cornerRadius(30)
            .shadow(radius: 5)
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .offset(x: 8)
                    .frame(width: 44 + self.controlWidthOffset, height: 44, alignment: .leading)
                    .foregroundColor(Color.primaryBlue)
                    .overlay(
                        HStack {
                            Spacer()
                            Image("RightChevronLight")
                                .frame(height: 16)
                                .offset(x: -8)
                        }
                    )
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let initialControlWidth: CGFloat = 44
                                let controlWidthOffsetLimit = geometry.size.width - self.horizontalPadding - initialControlWidth
                                let translationWidth = value.translation.width
                                
                                let controlWidthOffset: CGFloat = {
                                    if translationWidth < 0 {
                                        return .zero
                                    } else if translationWidth > controlWidthOffsetLimit {
                                        return controlWidthOffsetLimit
                                    } else {
                                        return translationWidth
                                    }
                                }()
                                
                                self.controlWidthOffset = controlWidthOffset
                            }
                            .onEnded { _ in
                                withAnimation {
                                    self.controlWidthOffset = .zero
                                }
                            }
                    )
                    .animation(.easeOut),
            alignment: .leading
            )
        }.frame(maxHeight: 44)
    }
    
}

struct Slider_Previews: PreviewProvider {
    static var previews: some View {
        Slider(titleText: "Slide for awake confirmation.")
    }
}
