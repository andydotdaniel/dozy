//
//  AwakeConfirmationRouter.swift
//  Dozy
//
//  Created by Andrew Daniel on 2/12/21.
//  Copyright © 2021 Andrew Daniel. All rights reserved.
//

import Foundation

protocol AwakeConfirmationRouter {
    func navigateToSchedule(with schedule: Schedule, isPostMessageSent: ScheduledMessageStatus)
}

class AwakeConfirmationViewRouter: AwakeConfirmationRouter {
    
    private weak var navigationControllable: NavigationControllable?
    private let userDefaults: ScheduleUserDefaults
    
    init(navigationControllable: NavigationControllable?, userDefaults: ScheduleUserDefaults) {
        self.navigationControllable = navigationControllable
        self.userDefaults = userDefaults
    }
    
    func navigateToSchedule(with schedule: Schedule, isPostMessageSent: ScheduledMessageStatus) {
        let scheduleViewController = ScheduleViewBuilder(
            schedule: schedule,
            isPostMessageSent: isPostMessageSent,
            navigationControllable: navigationControllable,
            scheduleUserDefaults: userDefaults
        ).buildViewController()
        navigationControllable?.pushViewController(scheduleViewController, animated: true)
        navigationControllable?.viewControllers = [scheduleViewController]
    }
    
}
