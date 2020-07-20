//
//  ScheduleViewPresenter.swift
//  Dozy
//
//  Created by Andrew Daniel on 7/19/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import SwiftUI

protocol ScheduleViewPresenter {
    var viewModel: ScheduleViewModel { get set }
}

class SchedulePresenter: ScheduleViewPresenter, ObservableObject {
    
    @Published var viewModel: ScheduleViewModel
    
    init(viewModel: ScheduleViewModel) {
        self.viewModel = viewModel
    }
    
}
