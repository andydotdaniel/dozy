//
//  ScheduleViewPresenter.swift
//  Dozy
//
//  Created by Andrew Daniel on 7/19/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import SwiftUI

protocol ScheduleViewPresenter: SwitchViewDelegate {}

class SchedulePresenter: ScheduleViewPresenter {
    
    private var viewModel: ScheduleViewModel
    
    init(viewModel: ScheduleViewModel) {
        self.viewModel = viewModel
    }
    
    func onSwitchPositionChanged(position: Switch.Position) {
        self.viewModel.state = position == .on ? .active : .inactive
    }
    
}
