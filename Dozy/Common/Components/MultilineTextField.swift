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

    private let placeholderText: String?
    @Binding var text: String?
    
    init(placeholderText: String? = nil, text: Binding<String?>) {
        self.placeholderText = placeholderText
        self._text = text
        
        super.init()
        
        if text.wrappedValue == nil && placeholderText != nil {
            self.text = placeholderText
        }
    }
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView(frame: .zero)
        textView.font = UIFont.systemFont(ofSize: 16)
        
        textView.text = self.text
        
        let isTextEmpty = self.text?.isEmpty ?? true
        textView.textColor = isTextEmpty ? UIColor.placeholderGray : UIColor.label
        textView.delegate = self
        textView.contentInset = .zero
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.delegate = self
    }
    
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
    
    func textViewDidChange(_ textView: UITextView) {
        self.text = textView.text
    }
    
}
