//
//  OnboardingPresenter.swift
//  Dozy
//
//  Created by Andrew Daniel on 8/2/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import Foundation
import UIKit

protocol OnboardingViewPresenter: MessageFormDelegate {
    func didTapCreateMessageButton()
}

class OnboardingPresenter: OnboardingViewPresenter {
    
    private let userDefaults: ScheduleUserDefaults
    var router: OnboardingRouter?
    
    init(userDefaults: ScheduleUserDefaults) {
        self.userDefaults = userDefaults
    }
    
    func onMessageSaved(_ message: Message) {
        let oneDay: TimeInterval = 60 * 60 * 24
        let schedule = Schedule(message: message, awakeConfirmationTime: Current.now().addingTimeInterval(oneDay), scheduledMessageId: nil)
        userDefaults.save(schedule)
        router?.dismissMessageForm(completion: {
            self.router?.navigateToSchedule(schedule: schedule, userDefaults: self.userDefaults)
        })
    }
    
    func didTapCreateMessageButton() {
        router?.presentMessageForm()
    }
    
}
