//
//  UserDefaultsMock.swift
//  DozyTests
//
//  Created by Andrew Daniel on 8/13/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

@testable import Dozy
import Foundation

class ScheduleUserDefaultsMock: ScheduleUserDefaultable {
    
    var scheduleSaved: Schedule?
    func saveSchedule(_ schedule: Schedule) {
        self.scheduleSaved = schedule
    }
    
    func loadSchedule() -> Schedule? {
        return nil
    }
    
}
