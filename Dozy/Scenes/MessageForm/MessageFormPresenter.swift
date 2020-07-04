//
//  MessageFormPresenter.swift
//  Dozy
//
//  Created by Andrew Daniel on 7/5/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import Foundation

protocol MessageFormViewPresenter {
    func didTapChannelDropdown()
}

class MessageFormPresenter: MessageFormViewPresenter {
    
    private var viewModel: MesssageFormViewModel
    
    init(viewModel: MesssageFormViewModel) {
        self.viewModel = viewModel
    }
    
    func didTapChannelDropdown() {
        viewModel.isShowingChannelDropdown = true
    }
    
}
