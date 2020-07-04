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
    @Published var channelName: String {
        didSet {
            if channelName.isEmpty {
                channelNameTextFieldColor = Color.placeholderGray
            } else {
                channelNameTextFieldColor = Color.black
            }
        }
    }
    @Published var channelNameTextFieldColor: Color
    @Published var isShowingChannelDropdown: Bool
    @Published var channelItems: [ChannelItem]
    
    @Published var keyboardHeight: CGFloat
    private var keyboardListener: KeyboardListener
    private var keyboardListenerSink: AnyCancellable?
    
    init(navigationBarTitle: String, channelName: String = "") {
        self.navigationBarTitle = navigationBarTitle
        self.channelName = channelName
        self.channelNameTextFieldColor = Color.placeholderGray
        self.keyboardHeight = 0
        
        self.isShowingChannelDropdown = false
        self.channelItems = [
            ChannelItem(isPublic: true, text: "Channel 2"),
            ChannelItem(isPublic: true, text: "Channel 3")
        ]
        
        let keyboardListener = KeyboardListener()
        self.keyboardListener = keyboardListener
        self.keyboardListenerSink = keyboardListener.$keyboardHeight.sink { self.keyboardHeight = $0 }
    }
}
