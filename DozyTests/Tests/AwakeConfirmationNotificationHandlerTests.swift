//
//  AwakeConfirmationNotificationHandlerTests.swift
//  DozyTests
//
//  Created by Andrew Daniel on 12/17/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

@testable import Dozy
import XCTest

class AwakeConfirmationNotificationHandlerTests: XCTestCase {
    
    private var notificationHandler: AwakeConfirmationNotificationHandler!
    private var navigationControllableMock: NavigationControllableMock!
    private var scheduleUserDefaultsMock: ScheduleUserDefaultsMock!
    
    private var message: Message {
        Message(image: nil, bodyText: "SOME_BODY_TEXT", channel: channel)
    }
    
    private var channel: Channel {
        Channel(id: "SOME_CHANNEL_ID", isPublic: false, text: "SOME_CHANNEL_NAME")
    }

    override func setUpWithError() throws {
        navigationControllableMock = NavigationControllableMock()
        scheduleUserDefaultsMock = ScheduleUserDefaultsMock()
        
        notificationHandler = AwakeConfirmationNotificationHandler(
            navigationControllable: navigationControllableMock,
            scheduleUserDefaults: scheduleUserDefaultsMock
        )
    }

    override func tearDownWithError() throws {
        scheduleUserDefaultsMock = nil
        navigationControllableMock = nil
        notificationHandler = nil
    }

    func testNavigateToAwakeConfirmationView() {
        scheduleUserDefaultsMock.scheduleSaved = Schedule(
            message: message,
            awakeConfirmationTime: Current.now(),
            scheduledMessageId: "SOME_SCHEDULED_MESSAGE_ID"
        )
        
        notificationHandler.routeToValidScreen()
        
        XCTAssertTrue(navigationControllableMock?.pushViewControllerCalledWithArgs?.viewController is AwakeConfirmationViewController)
        XCTAssertEqual(navigationControllableMock?.pushViewControllerCalledWithArgs?.animated, false)
    }
    
    func testNavigateToScheduleView() {
        scheduleUserDefaultsMock.scheduleSaved = Schedule(
            message: message,
            awakeConfirmationTime: Current.now().addingTimeInterval(-awakeConfirmationDelay),
            scheduledMessageId: "SOME_SCHEDULED_MESSAGE_ID"
        )
        
        notificationHandler.routeToValidScreen()
        
        XCTAssertTrue(navigationControllableMock?.pushViewControllerCalledWithArgs?.viewController is ScheduleViewController)
        XCTAssertEqual(navigationControllableMock?.pushViewControllerCalledWithArgs?.animated, false)
    }

}
