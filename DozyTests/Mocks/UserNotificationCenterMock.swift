//
//  UserNotificationCenterMock.swift
//  DozyTests
//
//  Created by Andrew Daniel on 12/29/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import Foundation
@testable import Dozy
import UserNotifications

class UserNotificationCenterMock: UserNotificationCenter {
    
    var requestIdentifierAdded: String?
    func add(request: UNNotificationRequest, completion: ((Error?) -> Void)?) {
        requestIdentifierAdded = request.identifier
    }
    
    var identifiersRemoved: [String]?
    func removePendingNotificationRequests(withIdentifiers identifiers: [String]) {
        identifiersRemoved = identifiers
    }
    
}
