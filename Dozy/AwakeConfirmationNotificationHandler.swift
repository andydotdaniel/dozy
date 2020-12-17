//
//  AwakeConfirmationNotificationHandler.swift
//  Dozy
//
//  Created by Andrew Daniel on 12/16/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import Foundation
import UIKit

class AwakeConfirmationNotificationHandler {
    
    private weak var navigationControllable: NavigationControllable?
    private let scheduleUserDefaults: ScheduleUserDefaults
    
    init(navigationControllable: NavigationControllable, scheduleUserDefaults: ScheduleUserDefaults) {
        self.navigationControllable = navigationControllable
        self.scheduleUserDefaults = scheduleUserDefaults
    }
    
    func routeToValidScreen() {
        guard let schedule = scheduleUserDefaults.load() else { return }
        let now = Current.now()
        
        let targetViewController: UIViewController = {
            switch now.compare(schedule.sleepyheadMessagePostTime) {
            case .orderedDescending, .orderedSame:
                return ScheduleViewBuilder(schedule: schedule, navigationControllable: navigationControllable).buildViewController()
            case .orderedAscending:
                return AwakeConfirmationViewBuilder(schedule: schedule, navigationControllable: navigationControllable).buildViewController()
            }
        }()
        
        navigationControllable?.pushViewController(targetViewController, animated: false)
    }
    
}
