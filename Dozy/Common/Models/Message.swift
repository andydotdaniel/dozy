//
//  Message.swift
//  Dozy
//
//  Created by Andrew Daniel on 7/19/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import UIKit

struct Message {
    let image: UIImage?
    let bodyText: String?
    let channel: Channel
    let awakeConfirmationTime: Date
}

extension Message {
    
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
