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
            self.awakeConfirmationCard.state = (state == .active) ? .enabled : .disabled
        }
    }
    @Published var awakeConfirmationCard: ContentCard.ViewModel
    @Published var messageCard: MessageContentCard.ViewModel
    
    init(schedule: Schedule) {
        self.state = schedule.isActive ? .active : .inactive
         
        let bodyText: Text = Text("Open the app in ")
            .foregroundColor(Color.white) +
        Text("07:18:36")
            .foregroundColor(Color.white)
            .bold() +
        Text(" or your sleepyhead message gets sent.")
            .foregroundColor(Color.white)
        
        self.awakeConfirmationCard = ContentCard.ViewModel(
            state: schedule.isActive ? .enabled : .disabled,
            titleText: schedule.awakeConfirmationDateText,
            subtitleText: schedule.awakeConfirmationTimeText,
            bodyText: bodyText,
            buttonText: "Change awake confirmation time"
        )
        
        let messageImage = schedule.message.image.map { UIImage(data: $0) } ?? nil
        let channel = schedule.message.channel
        self.messageCard = MessageContentCard.ViewModel(
            image: messageImage,
            bodyText: schedule.message.bodyText,
            actionButton: (titleText: "Edit", tapAction: {}),
            channel: (isPublic: channel.isPublic, text: channel.text)
        )
    }
    
}
