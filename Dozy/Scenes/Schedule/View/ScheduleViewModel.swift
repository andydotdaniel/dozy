//
//  ScheduleViewModel.swift
//  Dozy
//
//  Created by Andrew Daniel on 7/19/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import SwiftUI

class ScheduleViewModel: ObservableObject {
    
    enum State {
        case active
        case inactive
    }
    
    @Published var state: State {
        didSet {
            self.contentCardState = (state == .active) ? .enabled : .disabled
            self.switchState = (state == .active) ? .on : .off
        }
    }
    @Published var contentCardState: ContentCard.State
    @Published var switchState: Switch.State
    
    init(state: State) {
        self.state = state
        self.contentCardState = (state == .active) ? .enabled : .disabled
        self.switchState = (state == .active) ? .on : .off
    }
}
