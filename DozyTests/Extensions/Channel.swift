//
//  Channel.swift
//  DozyTests
//
//  Created by Andrew Daniel on 8/12/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

@testable import Dozy
import Foundation

extension Channel: Equatable {
    
    public static func == (lhs: Channel, rhs: Channel) -> Bool {
        return lhs.id == rhs.id &&
            lhs.isPublic == rhs.isPublic &&
            lhs.text == rhs.text
    }
    
}
