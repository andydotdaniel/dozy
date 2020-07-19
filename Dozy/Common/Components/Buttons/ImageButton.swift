//
//  ImageButton.swift
//  Dozy
//
//  Created by Andrew Daniel on 7/12/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import SwiftUI

struct ImageButton: View {
    
    let image: UIImage
    let titleText: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(width: 48)
            Text(titleText)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(Color.placeholderGray)
        }
    }
}

struct ImageButton_Previews: PreviewProvider {
    static var previews: some View {
        ImageButton(image: UIImage(named: "IconImagePlaceholder")!, titleText: "Some Title Text")
    }
}
