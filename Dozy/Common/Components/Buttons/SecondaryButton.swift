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
    let backgroundColor: Color
    let foregroundColor: Color
    
    var body: some View {
        Text(titleText)
        .font(.system(size: 16))
        .fontWeight(.semibold)
        .foregroundColor(foregroundColor)
        .truncationMode(.tail)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(backgroundColor)
        .cornerRadius(24)
        .onTapGesture {
            tapAction()
        }
    }
    
}

struct SecondaryButton_Previews: PreviewProvider {
    static var previews: some View {
        SecondaryButton(
            titleText: "Change awake confirmation time",
            tapAction: {},
            backgroundColor: .white,
            foregroundColor: .alertRed
        )
    }
}
