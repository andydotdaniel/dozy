//
//  KeychainMock.swift
//  DozyTests
//
//  Created by Andrew Daniel on 6/21/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import Foundation
@testable import Dozy

class KeychainMock: SecureStorable {
    
    var saveKey: String?
    var saveData: Data?
    func save(key: String, data: Data) -> OSStatus {
        saveKey = key
        saveData = data
        
        return 100
    }
    
    var dataToLoad: Data?
    func load(key: String) -> Data? {
        return dataToLoad
    }
    
    var deleteKey: String?
    func delete(key: String) throws {
        deleteKey = key
    }
    
}
