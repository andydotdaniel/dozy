//
//  AddToSlackButton.swift
//  Dozy
//
//  Created by Andrew Daniel on 1/3/21.
//  Copyright © 2021 Andrew Daniel. All rights reserved.
//

import Foundation
import SwiftUI

struct AddToSlackButton: View {
    let tapAction: () -> Void
    
    @Binding var isLoading: Bool
    
    var body: some View {
        Button(action: tapAction) {
            getButtonContent()
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Color.borderGray, lineWidth: 1)
            )
        }
    }
    
    private func getButtonContent() -> AnyView {
        if !self.isLoading {
            return AnyView (
                HStack(spacing: 12) {
                    Image("SlackLogo")
                        .renderingMode(.original)
                        .frame(width: 30, height: 30)
                        .scaledToFit()
                    HStack(spacing: 0) {
                        Text("Add to ")
                            .font(.system(size: 21))
                            .fontWeight(.medium)
                            .foregroundColor(Color.black)
                        Text("Slack")
                            .font(.system(size: 21))
                            .fontWeight(.bold)
                            .foregroundColor(Color.black)
                    }
                }
            )
        } else {
            return AnyView(Spinner(strokeColor: Color.primaryBlue))
        }
    }
}


struct AddToSlackButton_Previews: PreviewProvider {
    
    static var previews: some View {
        AddToSlackButton(tapAction: { }, isLoading: .constant(false))
    }
    
}
