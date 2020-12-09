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
    
    struct MessageCardViewModel {
        let image: UIImage?
        let bodyText: String?
        let channel: (isPublic: Bool, text: String)
        let actionButtonTitle: String
    }
    @Published var messageCard: MessageCardViewModel
    
    @Published var isShowingMessageForm: Bool = false
    
    @Published var switchPosition: (position: Switch.Position, isLoading: Bool)
    
    @Published var errorToastText: String?
    @Published var errorToastIsShowing: Bool = false
    
    init(schedule: Schedule) {
        self.state = schedule.isActive ? .active : .inactive
        self.switchPosition = schedule.isActive ? (.on, false) : (.off, false)
        
        self.awakeConfirmationCard = ContentCard.ViewModel(
            state: schedule.isActive ? .enabled : .disabled,
            titleText: schedule.awakeConfirmationDateText,
            subtitleText: schedule.awakeConfirmationTimeText,
            preMutableText: "",
            mutableText: "",
            postMutableText: "",
            buttonText: "Change awake confirmation time",
            timePickerDate: Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
        )
        
        let messageImage = schedule.message.image.map { UIImage(data: $0) } ?? nil
        let channel = schedule.message.channel
        self.messageCard = MessageCardViewModel(
            image: messageImage,
            bodyText: schedule.message.bodyText,
            channel: (isPublic: channel.isPublic, text: channel.text),
            actionButtonTitle: "Edit"
        )
    }
    
}
