//
//  UserDefaults.swift
//  Dozy
//
//  Created by Andrew Daniel on 8/1/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import Foundation

private let messageUserDefaultsKey = "message_user_defaults"

private struct CodableMessage: Codable {
    
    let image: Data?
    let bodyText: String?
    let channel: Channel
    let awakeConfirmationTime: Date
    
    init(from message: Message) {
        self.image = message.image?.pngData()
        self.bodyText = message.bodyText
        self.channel = message.channel
        self.awakeConfirmationTime = message.awakeConfirmationTime
    }
    
}

protocol MessageUserDefaultable {
    func saveMessage(_ message: Message)
}

extension UserDefaults: MessageUserDefaultable {
    
    func saveMessage(_ message: Message) {
        let codableMessage = CodableMessage(from: message)
        self.set(try? PropertyListEncoder().encode(codableMessage), forKey: messageUserDefaultsKey)
    }
    
}
