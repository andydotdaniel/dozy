//
//  ImagePickerButton.swift
//  Dozy
//
//  Created by Andrew Daniel on 7/2/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import Combine
import SwiftUI

struct ImagePickerButton: View {
    
    @Binding var selectedImage: UIImage?
    
    init(selectedImage: Binding<UIImage?>) {
        _selectedImage = selectedImage
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            createImage()
            Text(selectedImage == nil ? "Add image" : "Change image")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(Color.placeholderGray)
        }
    }
    
    private func createImage() -> AnyView {
        if let selectedImage = self.selectedImage {
            return AnyView(
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48)
            )
        } else {
            return AnyView(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.borderGray, lineWidth: 1.0)
                    .frame(width: 48, height: 48)
                    .overlay(
                        Image("IconImagePlaceholder")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24)
                    )
            )
        }
    }
    
}

struct ImagePickerButton_Previews: PreviewProvider {
    static var previews: some View {
        ImagePickerButton(selectedImage: .constant(nil))
    }
}
