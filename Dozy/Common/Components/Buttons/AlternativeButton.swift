//
//  AlternativeButton.swift
//  Dozy
//
//  Created by Andrew Daniel on 6/14/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import SwiftUI

struct AlternativeButton: View {
    let titleText: String
    let tapAction: () -> Void
    let icon: Image?
    
    @Binding var isLoading: Bool
    
    var body: some View {
        Button(action: tapAction) {
            getButtonContent()
            .frame(maxWidth: .infinity)
            .padding(.horizontal, self.isLoading ? 24 : 54)
            .padding(.vertical, 12)
            .overlay(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .stroke(Color.borderGray, lineWidth: 1)
            )
        }
    }
    
    private func getButtonContent() -> AnyView {
        if !self.isLoading {
            return AnyView (
                HStack(spacing: 12) {
                    icon?
                        .renderingMode(.original)
                        .frame(width: 30, height: 30)
                        .scaledToFit()
                    
                    Text(titleText)
                        .font(.system(size: 21))
                        .bold()
                        .foregroundColor(Color.black)
                }
            )
        } else {
            return AnyView(Spinner(strokeColor: Color.primaryBlue))
        }
    }
}

struct AlternativeButton_Previews: PreviewProvider {
    
    static var previews: some View {
        AlternativeButton(titleText: "Some Text", tapAction: { }, icon: Image("SlackLogo"), isLoading: .constant(false))
    }
    
}
