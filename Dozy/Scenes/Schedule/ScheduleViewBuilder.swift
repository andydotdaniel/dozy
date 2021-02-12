//
//  ScheduleViewBuilder.swift
//  Dozy
//
//  Created by Andrew Daniel on 7/19/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
import UserNotifications

class ScheduleViewController: UIHostingController<ScheduleView> {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
}

struct ScheduleViewBuilder: ViewControllerBuilder {
    
    private let schedule: Schedule
    private weak var navigationControllable: NavigationControllable?
    private let scheduleUserDefaults: ScheduleUserDefaults
    private let isPostMessageSent: ScheduledMessageStatus
    
    init(
        schedule: Schedule,
        isPostMessageSent: ScheduledMessageStatus,
        navigationControllable: NavigationControllable?,
        scheduleUserDefaults: ScheduleUserDefaults
    ) {
        self.schedule = schedule
        self.isPostMessageSent = isPostMessageSent
        self.navigationControllable = navigationControllable
        self.scheduleUserDefaults = scheduleUserDefaults
    }
    
    func buildViewController() -> UIViewController {
        let viewModel = ScheduleViewModel(schedule: schedule)
        let presenter = SchedulePresenter(
            schedule: schedule,
            isPostMessageSent: isPostMessageSent,
            viewModel: viewModel,
            userDefaults: scheduleUserDefaults,
            networkService: NetworkService(),
            keychain: Keychain(),
            navigationControllable: navigationControllable,
            awakeConfirmationTimer: ActionTimer(),
            userNotificationCenter: UNUserNotificationCenter.current()
        )
        let view = ScheduleView(viewModel: viewModel, presenter: presenter)
        
        return ScheduleViewController(rootView: view)
    }
    
}
