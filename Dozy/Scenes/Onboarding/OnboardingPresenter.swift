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
    private let userDefaults: ScheduleUserDefaults
    
    private weak var navigationControllable: NavigationControllable?
    
    init(
        viewModel: OnboardingViewModel,
        userDefaults: ScheduleUserDefaults = ScheduleUserDefaults(),
        navigationControllable: NavigationControllable?
    ) {
        self.viewModel = viewModel
        self.userDefaults = userDefaults
        self.navigationControllable = navigationControllable
    }
    
    func onMessageSaved(_ message: Message) {
        let oneDay: TimeInterval = 60 * 60 * 24
        let schedule = Schedule(message: message, awakeConfirmationTime: Date().addingTimeInterval(oneDay), scheduledMessageId: nil)
        userDefaults.save(schedule)
        viewModel.isShowingMessageForm = false
        
        let scheduleViewController = ScheduleViewBuilder(
            schedule: schedule,
            navigationControllable: navigationControllable,
            scheduleUserDefaults: userDefaults
        ).buildViewController()
        navigationControllable?.pushViewController(scheduleViewController, animated: false)
    }
    
}
