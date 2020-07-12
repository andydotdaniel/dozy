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

    func testAddMessageBuilder() throws {
        let builder = MessageFormViewBuilder(hasMessage: false)
        let view = builder.build()
        XCTAssertEqual(view.viewModel.navigationBarTitle, "Add message")
    }
    
    func testEditMessageBuilder() throws {
        let builder = MessageFormViewBuilder(hasMessage: true)
        let view = builder.build()
        XCTAssertEqual(view.viewModel.navigationBarTitle, "Edit message")
    }

}
