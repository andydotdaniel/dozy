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
            self.contentCard.state = (state == .active) ? .enabled : .disabled
        }
    }
    @Published var contentCard: ContentCard.ViewModel
    
    init(state: State, schedule: Schedule) {
        self.state = state
        self.contentCard = ScheduleViewModel.createContentCardViewModel(from: schedule, with: state)
    }
    
    private static func createContentCardViewModel(from schedule: Schedule, with state: State) -> ContentCard.ViewModel {
        let bodyText: Text = Text("Open the app in ")
            .foregroundColor(Color.white) +
        Text("07:18:36")
            .foregroundColor(Color.white)
            .bold() +
        Text(" or your sleepyhead message gets sent.")
            .foregroundColor(Color.white)
        
        return ContentCard.ViewModel(
            state: state == .active ? .enabled : .disabled,
            titleText: schedule.awakeConfirmationDateText,
            subtitleText: schedule.awakeConfirmationTimeText,
            bodyText: bodyText,
            buttonText: "Change awake confirmation time"
        )
    }
    
}
