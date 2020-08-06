//
//  ScheduleViewBuilder.swift
//  Dozy
//
//  Created by Andrew Daniel on 7/19/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import Foundation

struct ScheduleViewBuilder: ViewBuilder {
    
    private let schedule: Schedule
    
    init(schedule: Schedule) {
        self.schedule = schedule
    }
    
    func build() -> ScheduleView {
        let viewModel = ScheduleViewModel(schedule: schedule)
        let presenter = SchedulePresenter(viewModel: viewModel)
        let view = ScheduleView(viewModel: viewModel, presenter: presenter)
        
        return view
    }
    
}
