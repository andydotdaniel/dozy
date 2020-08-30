//
//  OnboardingPresenter.swift
//  Dozy
//
//  Created by Andrew Daniel on 8/2/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import Foundation
import UIKit

protocol OnboardingViewPresenter: MessageFormDelegate {}

class OnboardingPresenter: OnboardingViewPresenter {
    
    private var viewModel: OnboardingViewModel
    private let userDefaults: ScheduleUserDefaultable
    
    init(viewModel: OnboardingViewModel, userDefaults: ScheduleUserDefaultable = UserDefaults.standard) {
        self.viewModel = viewModel
        self.userDefaults = userDefaults
    }
    
    func onMessageSaved(_ message: Message) {
        let schedule = Schedule(message: message, awakeConfirmationTime: Date(), scheduledMessageId: nil)
        userDefaults.saveSchedule(schedule)
        
        self.viewModel.messageCreatedNavigationDestination = ScheduleViewBuilder(schedule: schedule).build()
        self.viewModel.shouldNavigateToSchedule = true
        self.viewModel.isShowingMessageForm = false
    }
    
}
