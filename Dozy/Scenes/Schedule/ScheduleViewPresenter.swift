//
//  ScheduleViewPresenter.swift
//  Dozy
//
//  Created by Andrew Daniel on 7/19/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import SwiftUI

protocol ScheduleViewPresenter: SwitchViewDelegate, MessageFormDelegate {
    func onMessageActionButtonTapped()
    func navigateToMessageForm() -> MessageFormView
}

class SchedulePresenter: ScheduleViewPresenter {
    
    private var viewModel: ScheduleViewModel
    private let userDefaults: ScheduleUserDefaultable
    private var schedule: Schedule
    
    init(schedule: Schedule, viewModel: ScheduleViewModel, userDefaults: ScheduleUserDefaultable = UserDefaults.standard) {
        self.viewModel = viewModel
        self.userDefaults = userDefaults
        self.schedule = schedule
    }
    
    func onSwitchPositionChanged(position: Switch.Position) {
        self.viewModel.state = position == .on ? .active : .inactive
    }
    
    func onMessageActionButtonTapped() {
        self.viewModel.isShowingMessageForm = true
    }
    
    func onMessageSaved(_ message: Message) {
        let schedule = Schedule(
            message: message,
            awakeConfirmationTime: self.schedule.awakeConfirmationTime,
            isActive: self.schedule.isActive
        )
        userDefaults.saveSchedule(schedule)
        
        updateMessageCard(with: message)
        
        self.schedule = schedule
        self.viewModel.isShowingMessageForm = false
    }
    
    private func updateMessageCard(with message: Message) {
        let image = message.image.map { UIImage(data: $0) } ?? nil
        self.viewModel.messageCard = ScheduleViewModel.MessageCardViewModel(
            image: image,
            bodyText: message.bodyText,
            channel: (isPublic: message.channel.isPublic, text: message.channel.text),
            actionButtonTitle: self.viewModel.messageCard.actionButtonTitle
        )
    }
    
    func navigateToMessageForm() -> MessageFormView {
        MessageFormViewBuilder(message: self.schedule.message, delegate: self).build()
    }
    
}
