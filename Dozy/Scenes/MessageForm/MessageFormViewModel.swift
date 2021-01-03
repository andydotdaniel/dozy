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
    
    @Published var isSaving: Bool
    @Published var isShowingImageUploadConfirmation: Bool
    @Published var isShowingSaveError: Bool
    @Published var isFetchingChannels: Bool
    @Published var isShowingChannelFetchError: Bool
    
    @Published var isSaveButtonEnabled: Bool
    private var saveButtonEnabledPublisher: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest(isChannelNameEmptyPublisher, isMessageContentValidPublisher)
            .map { channelNameEmpty, messageContentValid in
                return !channelNameEmpty && messageContentValid
            }
            .eraseToAnyPublisher()
    }
    
    private var isChannelNameEmptyPublisher: AnyPublisher<Bool, Never> {
        $channelNameTextFieldText
            .removeDuplicates()
            .map { channelName in
                channelName.isEmpty
            }
            .eraseToAnyPublisher()
    }
    
    private var isMessageContentValidPublisher: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest($bodyText, $selectedImage)
            .map { bodyText, selectedImage in
                bodyText?.isEmpty == false || selectedImage != nil
            }
            .eraseToAnyPublisher()
    }
    
    private var cancellableSet = Set<AnyCancellable>()
    
    init(navigationBarTitle: String, message: Message?) {
        self.navigationBarTitle = navigationBarTitle
        self.channelNameTextFieldText = message?.channel.text ?? ""
        self.channelNameTextFieldColor = {
            if let message = message, !message.channel.text.isEmpty {
                return Color.black
            }
            return Color.placeholderGray
        }()
        self.bodyText = message?.bodyText
        
        self.isShowingChannelDropdown = false
        self.filteredChannelItems = []
        
        self.isShowingImagePicker = false
        self.selectedImage = message?.uiImage
        
        self.isSaving = false
        self.isShowingImageUploadConfirmation = false
        self.isSaveButtonEnabled = false
        self.isShowingSaveError = false
        self.isFetchingChannels = false
        self.isShowingChannelFetchError = false
        
        self.saveButtonEnabledPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.isSaveButtonEnabled, on: self)
        .store(in: &cancellableSet)
    }
}
