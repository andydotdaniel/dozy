//
//  SecondaryButton.swift
//  Dozy
//
//  Created by Andrew Daniel on 7/18/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import SwiftUI

struct SecondaryButton: View {
    
    let titleText: String
    let tapAction: () -> Void
    let color: Color
    
    var body: some View {
        Button(action: tapAction) {
            Text(titleText)
                .font(.system(size: 16))
                .fontWeight(.semibold)
                .foregroundColor(Color.black)
                .opacity(0.35)
                .truncationMode(.tail)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(color)
        .cornerRadius(24)
    }
    
}

struct SecondaryButton_Previews: PreviewProvider {
    static var previews: some View {
        SecondaryButton(
            titleText: "Change awake confirmation time",
            tapAction: {},
            color: Color.darkBlue
        )
    }
}
