//
//  Schedule.swift
//  DozyTests
//
//  Created by Andrew Daniel on 8/13/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

@testable import Dozy
import Foundation

extension Schedule: Equatable {
    
    public static func == (lhs: Schedule, rhs: Schedule) -> Bool {
        return lhs.message == rhs.message &&
            lhs.awakeConfirmationTime == rhs.awakeConfirmationTime &&
            lhs.isActive == rhs.isActive
    }
    
}
