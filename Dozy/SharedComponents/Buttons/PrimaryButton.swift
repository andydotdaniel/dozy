//
//  PrimaryButton.swift
//  Dozy
//
//  Created by Andrew Daniel on 6/22/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import SwiftUI

struct PrimaryButton: View {
    
    let titleText: String
    let tapAction: () -> Void
    
    var body: some View {
        Button(action: tapAction) {
            Text(titleText)
            .font(.system(size: 21))
            .bold()
            .foregroundColor(Color.white)
        }
        .padding(.horizontal, 54)
        .padding(.vertical, 12)
        .background(Color.primaryBlue)
        .cornerRadius(30)
        .shadow(radius: 5)
    }
}

struct PrimaryButton_Previews: PreviewProvider {
    static var previews: some View {
        PrimaryButton(titleText: "Some Text", tapAction: {})
    }
}
