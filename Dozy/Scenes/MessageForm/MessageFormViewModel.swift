//
//  MessageFormViewModel.swift
//  Dozy
//
//  Created by Andrew Daniel on 7/5/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import Combine
import SwiftUI

class MesssageFormViewModel: ObservableObject {
    let navigationBarTitle: String
    @Published var channelNameTextFieldText: String {
        didSet {
            if channelNameTextFieldText.isEmpty {
                channelNameTextFieldColor = Color.placeholderGray
            } else {
                channelNameTextFieldColor = Color.black
            }
        }
    }
    
    @Published var channelNameTextFieldColor: Color
    @Published var isShowingChannelDropdown: Bool
    @Published var filteredChannelItems: [Channel]
    
    @Published var isShowingImagePicker: Bool
    @Published var selectedImage: UIImage?
    
    @Published var keyboardHeight: CGFloat
    private var keyboardListener: KeyboardListener
    private var keyboardListenerSink: AnyCancellable?
    
    init(navigationBarTitle: String, channelNameTextFieldText: String = "", selectedImage: UIImage? = nil) {
        self.navigationBarTitle = navigationBarTitle
        self.channelNameTextFieldText = channelNameTextFieldText
        self.channelNameTextFieldColor = Color.placeholderGray
        self.keyboardHeight = 0
        
        self.isShowingChannelDropdown = false
        self.filteredChannelItems = []
        
        self.isShowingImagePicker = false
        self.selectedImage = selectedImage
        
        let keyboardListener = KeyboardListener()
        self.keyboardListener = keyboardListener
        self.keyboardListenerSink = keyboardListener.$keyboardHeight.sink { self.keyboardHeight = $0 }
    }
}
