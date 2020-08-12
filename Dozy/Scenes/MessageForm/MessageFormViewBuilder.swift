//
//  MessageFormViewBuilder.swift
//  Dozy
//
//  Created by Andrew Daniel on 7/5/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import Foundation

protocol MessageFormDelegate: class {
    func onMessageSaved(_ message: Message)
}

struct MessageFormViewBuilder: ViewBuilder {
    
    private let hasMessage: Bool
    private weak var delegate: MessageFormDelegate?
    
    init(hasMessage: Bool, delegate: MessageFormDelegate) {
        self.hasMessage = hasMessage
        self.delegate = delegate
    }
    
    func build() -> MessageFormView {
        let navigationBarTitle = hasMessage ? "Edit message" : "Add message"
        let viewModel = MesssageFormViewModel(navigationBarTitle: navigationBarTitle)
        let presenter = MessageFormPresenter(viewModel: viewModel, networkService: NetworkService(), delegate: delegate)
        let view = MessageFormView(viewModel: viewModel, presenter: presenter)
        
        return view
    }
    
}
