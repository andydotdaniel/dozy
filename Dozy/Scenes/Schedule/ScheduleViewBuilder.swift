//
//  ScheduleViewBuilder.swift
//  Dozy
//
//  Created by Andrew Daniel on 7/19/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import Foundation

struct ScheduleViewBuilder: ViewBuilder {
    
    func build() -> ScheduleView {
        let viewModel = ScheduleViewModel(state: .active)
        let presenter = SchedulePresenter(viewModel: viewModel)
        let view = ScheduleView(presenter: presenter)
        
        return view
    }
    
}
