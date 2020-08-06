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
    
    init(schedule: Schedule) {
        self.state = schedule.isActive ? .active : .inactive
        self.contentCard = ScheduleViewModel.createContentCardViewModel(from: schedule)
    }
    
    private static func createContentCardViewModel(from schedule: Schedule) -> ContentCard.ViewModel {
        let bodyText: Text = Text("Open the app in ")
            .foregroundColor(Color.white) +
        Text("07:18:36")
            .foregroundColor(Color.white)
            .bold() +
        Text(" or your sleepyhead message gets sent.")
            .foregroundColor(Color.white)
        
        return ContentCard.ViewModel(
            state: schedule.isActive ? .enabled : .disabled,
            titleText: schedule.awakeConfirmationDateText,
            subtitleText: schedule.awakeConfirmationTimeText,
            bodyText: bodyText,
            buttonText: "Change awake confirmation time"
        )
    }
    
}
