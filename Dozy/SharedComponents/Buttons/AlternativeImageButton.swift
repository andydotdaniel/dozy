//
//  AlternativeImageButton.swift
//  Dozy
//
//  Created by Andrew Daniel on 7/2/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import SwiftUI

struct AlternativeImageButton: View {
    
    let imageName: String
    let titleText: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.borderGray, lineWidth: 1.0)
                .frame(width: 48, height: 48)
                .overlay(
                    Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24)
                )
            Text(titleText)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(Color.placeholderGray)
        }
    }
    
}

struct AlternativeImageButton_Previews: PreviewProvider {
    static var previews: some View {
        AlternativeImageButton(imageName: "IconImagePlaceholder", titleText: "Add Image")
    }
}
