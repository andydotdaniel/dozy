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
    func didTapChannelItem(id: UUID)
}

class MessageFormPresenter: MessageFormViewPresenter {
    
    private var viewModel: MesssageFormViewModel
    
    init(viewModel: MesssageFormViewModel) {
        self.viewModel = viewModel
    }
    
    func didTapChannelDropdown() {
        viewModel.isShowingChannelDropdown = true
    }
    
    func didTapChannelItem(id: UUID) {
        viewModel.isShowingChannelDropdown = false
        if let channelName = viewModel.channelItems.first(where: { $0.id == id })?.text {
            viewModel.selectedChannelName = channelName
        }
    }
    
}
