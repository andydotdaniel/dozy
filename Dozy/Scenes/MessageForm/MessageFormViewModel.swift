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
    
    @Published var bodyText: String?
    
    @Published var isShowingImagePicker: Bool
    @Published var selectedImage: UIImage?
    
    @Published var keyboardHeight: CGFloat
    private var keyboardListener: KeyboardListener
    private var keyboardListenerSink: AnyCancellable?
    
    init(navigationBarTitle: String, message: Message?) {
        self.navigationBarTitle = navigationBarTitle
        self.channelNameTextFieldText = message?.channel.text ?? ""
        self.channelNameTextFieldColor = message?.channel.text == nil ? Color.placeholderGray : Color.black
        self.bodyText = message?.bodyText
        self.keyboardHeight = 0
        
        self.isShowingChannelDropdown = false
        self.filteredChannelItems = []
        
        self.isShowingImagePicker = false
        self.selectedImage = message?.image.map { UIImage(data: $0) } ?? nil
        
        let keyboardListener = KeyboardListener()
        self.keyboardListener = keyboardListener
        self.keyboardListenerSink = keyboardListener.$keyboardHeight.sink { self.keyboardHeight = $0 }
    }
}
