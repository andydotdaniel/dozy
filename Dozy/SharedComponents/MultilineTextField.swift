//
//  MultilineTextField.swift
//  Dozy
//
//  Created by Andrew Daniel on 7/1/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import UIKit
import SwiftUI

final class MultilineTextField: NSObject, UIViewRepresentable {

    let placeholderText: String?
    
    init(placeholderText: String? = nil) {
        self.placeholderText = placeholderText
    }
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView(frame: .zero)
        textView.font = UIFont.systemFont(ofSize: 16)
        
        textView.text = placeholderText
        textView.textColor = UIColor.placeholderGray
        textView.delegate = self
        textView.contentInset = .zero
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {}
    
}

extension MultilineTextField: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.placeholderGray {
            textView.text = nil
            textView.textColor = UIColor.label
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholderText
            textView.textColor = UIColor.placeholderGray
        }
    }
    
}
