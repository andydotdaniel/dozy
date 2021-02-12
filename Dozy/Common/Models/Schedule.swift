//
//  Schedule.swift
//  Dozy
//
//  Created by Andrew Daniel on 8/2/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import Foundation

let awakeConfirmationDelay: TimeInterval = 90

struct Schedule: Codable {
    let message: Message
    var awakeConfirmationTime: Date
    var scheduledMessageId: String?
}

extension Schedule {
    
    var isActive: Bool {
        scheduledMessageId != nil
    }
    
    var awakeConfirmationDateText: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "MMM d"
        return dateFormatter.string(from: awakeConfirmationTime)
    }
    
    var awakeConfirmationTimeText: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter.string(from: awakeConfirmationTime)
    }
    
    var delayedAwakeConfirmationTime: Date {
        // Add additional seconds delay to awake confirmation time because of the timer we show
        // in AwakeConfirmationView while the user confirms they are awake.
        return awakeConfirmationTime.addingTimeInterval(awakeConfirmationDelay)
    }
    
    var sleepyheadMessagePostTime: Date {
        // Add an additional 61 second delay because we cannot delete scheduled Slack messages
        // within 60 seconds of scheduled posting.
        // -- https://api.slack.com/methods/chat.deleteScheduledMessage#restrictions
        let slackDeleteRestrictionDelay: TimeInterval = 61
        return delayedAwakeConfirmationTime.addingTimeInterval(slackDeleteRestrictionDelay)
    }
    
}
