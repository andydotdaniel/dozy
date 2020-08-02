//
//  Schedule.swift
//  Dozy
//
//  Created by Andrew Daniel on 8/2/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import Foundation

struct Schedule: Codable {
    let message: Message
    let awakeConfirmationTime: Date
}

extension Schedule {
    
    var awakeConfirmationDateText: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        return dateFormatter.string(from: awakeConfirmationTime)
    }
    
    var awakeConfirmationTimeText: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mma"
        return dateFormatter.string(from: awakeConfirmationTime)
    }
    
}
