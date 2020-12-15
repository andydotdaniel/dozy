//
//  UserDefaults.swift
//  Dozy
//
//  Created by Andrew Daniel on 8/1/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import Foundation

class ObjectUserDefaults<T: Codable> {
    
    private let userDefaults: UserDefaults = UserDefaults.standard
    private let key: String
    
    init(key: String) {
        self.key = key
    }
    
    func save(_ object: T) {
        userDefaults.set(try? PropertyListEncoder().encode(object), forKey: key)
    }
    
    func load() -> T? {
        guard let data = userDefaults.object(forKey: key) as? Data else { return nil }
        return try? PropertyListDecoder().decode(T.self, from: data)
    }
    
    func delete() {
        userDefaults.removeObject(forKey: key)
    }
    
}

class ScheduleUserDefaults: ObjectUserDefaults<Schedule> {
    
    init() {
        super.init(key: "schedule_user_defaults")
    }
    
}

class ProfileUserDefaults: ObjectUserDefaults<Profile> {
    
    init() {
        super.init(key: "profile_user_defaults")
    }
    
}
