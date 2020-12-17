//
//  PostAwakeConfirmationTimeViewBuilder.swift
//  Dozy
//
//  Created by Andrew Daniel on 12/16/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import Foundation
import UIKit

class PostAwakeConfirmationTimeViewBuilder: ViewControllerBuilder {
    
    private weak var navigationControllable: NavigationControllable?
    private let schedule: Schedule
    private let now: Date
    
    init(navigationControllable: NavigationControllable?, schedule: Schedule, nowDate: Date) {
        self.navigationControllable = navigationControllable
        self.schedule = schedule
        self.now = nowDate
    }
    
    func buildViewController() -> UIViewController {
        switch now.compare(schedule.sleepyheadMessagePostTime) {
        case .orderedDescending, .orderedSame:
            return ScheduleViewBuilder(schedule: schedule, navigationControllable: navigationControllable).buildViewController()
        case .orderedAscending:
            return AwakeConfirmationViewBuilder(schedule: schedule, navigationControllable: navigationControllable).buildViewController()
        }
    }
    
}
