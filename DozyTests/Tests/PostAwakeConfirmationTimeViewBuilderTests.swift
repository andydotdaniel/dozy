//
//  PostAwakeConfirmationTimeViewBuilderTests.swift
//  DozyTests
//
//  Created by Andrew Daniel on 12/17/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

@testable import Dozy
import XCTest

class PostAwakeConfirmationTimeViewBuilderTests: XCTestCase {
    
    private var viewBuilder: PostAwakeConfirmationTimeViewBuilder!
    
    private var message: Message {
        Message(image: nil, bodyText: "SOME_BODY_TEXT", channel: channel)
    }
    
    private var channel: Channel {
        Channel(id: "SOME_CHANNEL_ID", isPublic: false, text: "SOME_CHANNEL_NAME")
    }

    override func setUpWithError() throws {
        Current = .mock
        let now = Date()
        Current.now = { now }
    }

    override func tearDownWithError() throws {
        viewBuilder = nil
        Current = World()
    }

    func testNavigateToAwakeConfirmationView() {
        let schedule = Schedule(
            message: message,
            awakeConfirmationTime: Current.now(),
            scheduledMessageId: "SOME_SCHEDULED_MESSAGE_ID"
        )
        viewBuilder = PostAwakeConfirmationTimeViewBuilder(navigationControllable: NavigationControllableMock(), schedule: schedule, nowDate: Current.now())
        XCTAssertTrue(viewBuilder.buildViewController() is AwakeConfirmationViewController)
    }
    
    func testNavigateToScheduleView() {
        let schedule = Schedule(
            message: message,
            awakeConfirmationTime: Current.now().addingTimeInterval(-awakeConfirmationDelay),
            scheduledMessageId: "SOME_SCHEDULED_MESSAGE_ID"
        )
        
        viewBuilder = PostAwakeConfirmationTimeViewBuilder(navigationControllable: NavigationControllableMock(), schedule: schedule, nowDate: Current.now())
        XCTAssertTrue(viewBuilder.buildViewController() is ScheduleViewController)
    }

}
