//
//  UserDefaultsMock.swift
//  DozyTests
//
//  Created by Andrew Daniel on 8/13/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

@testable import Dozy
import Foundation

class ScheduleUserDefaultsMock: ScheduleUserDefaults {
    
    var scheduleSaved: Schedule?
    
    override func save(_ object: Schedule) {
        scheduleSaved = object
    }
    
    override func load() -> Schedule? {
        return scheduleSaved
    }
    
    var deleteCalled: Bool = false
    override func delete() {
        deleteCalled = true
    }
    
}

class ProfileUserDefaultsMock: ProfileUserDefaults {
    
    var profileSaved: Profile?
    
    override func save(_ object: Profile) {
        profileSaved = object
    }
    
    override func load() -> Profile? {
        return profileSaved
    }
    
    var deleteCalled: Bool = false
    override func delete() {
        deleteCalled = true
    }
    
}
