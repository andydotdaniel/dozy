//
//  Message.swift
//  DozyTests
//
//  Created by Andrew Daniel on 8/12/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

@testable import Dozy
import Foundation

extension Message: Equatable {
    
    public static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.bodyText == rhs.bodyText &&
            lhs.image == rhs.image &&
            lhs.imageUrl == rhs.imageUrl &&
            lhs.channel == rhs.channel
    }
    
}
