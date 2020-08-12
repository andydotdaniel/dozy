//
//  MessageFormDelegateMock.swift
//  DozyTests
//
//  Created by Andrew Daniel on 8/12/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

@testable import Dozy
import Foundation

class MessageFormDelegateMock: MessageFormDelegate {
    
    var messageSaved: Message?
    func onMessageSaved(_ message: Message) {
        self.messageSaved = message
    }
    
}
