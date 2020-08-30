//
//  Keychain.swift
//  Dozy
//
//  Created by Andrew Daniel on 6/21/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import Foundation
import Security

protocol SecureStorable {
    func save(key: String, data: Data) -> OSStatus
    func load(key: String) -> Data?
}

final class Keychain: SecureStorable {
    
    struct Keys {
        static let slackAccessToken = "slack_access_token"
    }
    
    func save(key: String, data: Data) -> OSStatus {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecValueData: data
        ]
        
        SecItemDelete(query as CFDictionary)
        
        return SecItemAdd(query as CFDictionary, nil)
    }
    
    func load(key: String) -> Data? {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecReturnData: kCFBooleanTrue!,
            kSecMatchLimit: kSecMatchLimitOne
        ]

        var dataResultReference: AnyObject? = nil
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataResultReference)

        guard status == noErr else { return nil }
        return dataResultReference as? Data
    }
    
}
