//
//  OnboardingRouter.swift
//  Dozy
//
//  Created by Andrew Daniel on 12/30/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import Foundation
import UIKit

protocol OnboardingRouter {
    func presentMessageForm()
    func dismissMessageForm(completion: (() -> Void)?)
    
    func navigateToSchedule(schedule: Schedule, userDefaults: ScheduleUserDefaults)
}

class OnboardingViewRouter: OnboardingRouter {
    
    private weak var navigationControllable: NavigationControllable?
    private let messageFormViewBuilder: ViewControllerBuilder
    private weak var messageFormViewController: UIViewController?
    
    init(navigationControllable: NavigationControllable?, messageFormViewBuilder: ViewControllerBuilder) {
        self.navigationControllable = navigationControllable
        self.messageFormViewBuilder = messageFormViewBuilder
    }
    
    func presentMessageForm() {
        let messageFormViewController = messageFormViewBuilder.buildViewController()
        navigationControllable?.present(viewController: messageFormViewController, animated: true, completion: nil)
        
        self.messageFormViewController = messageFormViewController
    }
    
    func dismissMessageForm(completion: (() -> Void)?) {
        messageFormViewController?.dismiss(animated: true, completion: completion)
    }
    
    func navigateToSchedule(schedule: Schedule, userDefaults: ScheduleUserDefaults) {
        let scheduleViewController = ScheduleViewBuilder(
            schedule: schedule,
            isPostMessageSent: false,
            navigationControllable: self.navigationControllable,
            scheduleUserDefaults: userDefaults
        ).buildViewController()
        self.navigationControllable?.pushViewController(scheduleViewController, animated: true)
        self.navigationControllable?.viewControllers = [scheduleViewController]
    }
    
}
