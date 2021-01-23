//
//  AwakeConfirmationViewBuilder.swift
//  Dozy
//
//  Created by Andrew Daniel on 10/10/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

class AwakeConfirmationViewController: UIHostingController<AwakeConfirmationView> {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
}

struct AwakeConfirmationViewBuilder: ViewControllerBuilder {
    
    private let schedule: Schedule
    private let userDefaults: ScheduleUserDefaults
    private weak var navigationControllable: NavigationControllable?
    
    init(schedule: Schedule, userDefaults: ScheduleUserDefaults, navigationControllable: NavigationControllable?) {
        self.schedule = schedule
        self.userDefaults = userDefaults
        self.navigationControllable = navigationControllable
    }
    
    func buildViewController() -> UIViewController {
        let secondsLeft = schedule.sleepyheadMessagePostTime.timeIntervalSinceNow
        let viewModel = AwakeConfirmationViewModel(countdownActive: true, secondsLeft: Int(secondsLeft))
        let presenter = AwakeConfirmationPresenter(viewModel: viewModel, networkService: NetworkService(), keychain: Keychain(), userDefaults: userDefaults, savedSchedule: schedule, navigationControllable: navigationControllable, secondsLeftTimer: ActionTimer())
        let view = AwakeConfirmationView(viewModel: viewModel, presenter: presenter)
        
        return AwakeConfirmationViewController(rootView: view)
    }
    
}
