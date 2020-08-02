//
//  MessageFormViewBuilder.swift
//  Dozy
//
//  Created by Andrew Daniel on 7/5/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import Foundation

struct MessageFormViewBuilder: ViewBuilder {
    
    private let hasMessage: Bool
    
    init(hasMessage: Bool) {
        self.hasMessage = hasMessage
    }
    
    func build() -> MessageFormView {
        let navigationBarTitle = hasMessage ? "Edit message" : "Add message"
        let viewModel = MesssageFormViewModel(navigationBarTitle: navigationBarTitle)
        let presenter = MessageFormPresenter(viewModel: viewModel, networkService: NetworkService(), hasMessage: hasMessage)
        let view = MessageFormView(viewModel: viewModel, presenter: presenter)
        
        return view
    }
    
}
