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
    
    private let message: Message?
    private weak var delegate: MessageFormDelegate?
    
    init(message: Message?, delegate: MessageFormDelegate) {
        self.message = message
        self.delegate = delegate
    }
    
    func build() -> MessageFormView {
        let navigationBarTitle = message != nil ? "Edit message" : "Add message"
        let viewModel = MesssageFormViewModel(navigationBarTitle: navigationBarTitle, message: message)
        let presenter = MessageFormPresenter(viewModel: viewModel, networkService: NetworkService(), delegate: delegate, message: message)
        let view = MessageFormView(viewModel: viewModel, presenter: presenter)
        
        return view
    }
    
}
