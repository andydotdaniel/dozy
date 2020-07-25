//
//  ScheduleViewBuilder.swift
//  Dozy
//
//  Created by Andrew Daniel on 7/19/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import Foundation

struct ScheduleViewBuilder: ViewBuilder {
    
    private let message: Message
    private let state: ScheduleViewModel.State
    
    init(message: Message, state: ScheduleViewModel.State) {
        self.message = message
        self.state = state
    }
    
    func build() -> ScheduleView {
        let viewModel = ScheduleViewModel(state: state, message: message)
        let presenter = SchedulePresenter(viewModel: viewModel)
        let view = ScheduleView(viewModel: viewModel, presenter: presenter)
        
        return view
    }
    
}
