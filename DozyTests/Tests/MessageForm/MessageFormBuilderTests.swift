//
//  MessageFormBuilderTests.swift
//  DozyTests
//
//  Created by Andrew Daniel on 7/12/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import XCTest
@testable import Dozy

class MessageFormBuilderTests: XCTestCase {
    
    let delegateMock = MessageFormDelegateMock()
    
    func testAddMessageBuilder() throws {
        let builder = MessageFormViewBuilder(message: nil, delegate: delegateMock)
        let view = builder.build()
        XCTAssertEqual(view.viewModel.navigationBarTitle, "Add message")
    }
    
    func testEditMessageBuilder() throws {
        let channel = Channel(id: "SOME_CHANNEL_ID", isPublic: true, text: "NAME_OF_CHANNEL")
        let message = Message(imageName: nil, imageUrl: nil, bodyText: "SOME_BODY_TEXT", channel: channel)
        
        let builder = MessageFormViewBuilder(message: message, delegate: delegateMock)
        let view = builder.build()
        XCTAssertEqual(view.viewModel.navigationBarTitle, "Edit message")
    }

}
