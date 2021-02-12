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
    private let scheduleUserDefaults: ScheduleUserDefaults
    
    init(navigationControllable: NavigationControllable?, schedule: Schedule, scheduleUserDefaults: ScheduleUserDefaults, nowDate: Date) {
        self.navigationControllable = navigationControllable
        self.schedule = schedule
        self.scheduleUserDefaults = scheduleUserDefaults
        self.now = nowDate
    }
    
    func buildViewController() -> UIViewController {
        func comparePostDelayedAwakeConfirmationTimes(from date: Date) -> ScheduledMessageStatus {
            switch date.compare(schedule.sleepyheadMessagePostTime) {
            case .orderedDescending, .orderedSame:
                return .sent
            case .orderedAscending:
                return .confirmed
            }
        }
        
        guard schedule.isActive else { return getScheduleViewController(isPostMessageSent: .notSent) }
        
        switch now.compare(schedule.delayedAwakeConfirmationTime) {
        case .orderedDescending, .orderedSame:
            let isPostMessageSent = comparePostDelayedAwakeConfirmationTimes(from: now)
            return getScheduleViewController(isPostMessageSent: isPostMessageSent)
        case .orderedAscending:
            return AwakeConfirmationViewBuilder(schedule: schedule, userDefaults: scheduleUserDefaults, navigationControllable: navigationControllable).buildViewController()
        }
    }
    
    private func getScheduleViewController(isPostMessageSent: ScheduledMessageStatus) -> UIViewController {
        return ScheduleViewBuilder(
            schedule: schedule,
            isPostMessageSent: isPostMessageSent,
            navigationControllable: navigationControllable,
            scheduleUserDefaults: scheduleUserDefaults
        ).buildViewController()
    }
    
}
