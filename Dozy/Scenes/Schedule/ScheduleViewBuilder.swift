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

class ScheduleViewController: UIHostingController<ScheduleView> {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
}

struct ScheduleViewBuilder: ViewControllerBuilder {
    
    private let schedule: Schedule
    
    init(schedule: Schedule) {
        self.schedule = schedule
    }
    
    func buildViewController() -> UIViewController {
        let viewModel = ScheduleViewModel(schedule: schedule)
        let presenter = SchedulePresenter(schedule: schedule, viewModel: viewModel, userDefaults: UserDefaults.standard, networkService: NetworkService(), keychain: Keychain())
        let view = ScheduleView(viewModel: viewModel, presenter: presenter)
        
        return ScheduleViewController(rootView: view)
    }
    
}
