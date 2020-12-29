//
//  UNUserNotificationCenter.swift
//  Dozy
//
//  Created by Andrew Daniel on 12/29/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import Foundation
import UserNotifications

protocol UserNotificationCenter {
    func add(request: UNNotificationRequest, completion: ((Error?) -> Void)?)
    func removePendingNotificationRequests(withIdentifiers identifiers: [String])
}

extension UNUserNotificationCenter: UserNotificationCenter {
    
    func add(request: UNNotificationRequest, completion: ((Error?) -> Void)?) {
        add(request, withCompletionHandler: completion)
    }
    
}
