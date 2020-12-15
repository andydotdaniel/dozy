//
//  AwakeConfirmationViewBuilder.swift
//  Dozy
//
//  Created by Andrew Daniel on 10/10/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import Foundation

struct AwakeConfirmationViewBuilder: ViewBuilder {
    
    private let schedule: Schedule
    
    init(schedule: Schedule) {
        self.schedule = schedule
    }
    
    func build() -> AwakeConfirmationView {
        let secondsLeft = schedule.awakeConfirmationTime.timeIntervalSinceNow
        let viewModel = AwakeConfirmationViewModel(countdownActive: true, secondsLeft: Int(secondsLeft))
        let presenter = AwakeConfirmationPresenter(viewModel: viewModel, networkService: NetworkService(), keychain: Keychain(), userDefaults: ScheduleUserDefaults(), savedSchedule: schedule)
        
        return AwakeConfirmationView(viewModel: viewModel, presenter: presenter)
    }
    
}
