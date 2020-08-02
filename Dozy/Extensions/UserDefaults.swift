//
//  UserDefaults.swift
//  Dozy
//
//  Created by Andrew Daniel on 8/1/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import Foundation

private let scheduleUserDefaultsKey = "schedule_user_defaults"

protocol ScheduleUserDefaultable {
    func saveSchedule(_ schedule: Schedule)
    func loadSchedule() -> Schedule?
}

extension UserDefaults: ScheduleUserDefaultable {
    
    func saveSchedule(_ schedule: Schedule) {
        self.set(try? PropertyListEncoder().encode(schedule), forKey: scheduleUserDefaultsKey)
    }
    
    func loadSchedule() -> Schedule? {
        guard let scheduleData = self.object(forKey: scheduleUserDefaultsKey) as? Data else { return nil }
        
        return try? PropertyListDecoder().decode(Schedule.self, from: scheduleData)
    }
    
}
