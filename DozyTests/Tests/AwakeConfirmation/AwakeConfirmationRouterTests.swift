//
//  AwakeConfirmationRouterTests.swift
//  DozyTests
//
//  Created by Andrew Daniel on 2/12/21.
//  Copyright © 2021 Andrew Daniel. All rights reserved.
//

import XCTest
@testable import Dozy

class AwakeConfirmationRouterTests: XCTestCase {

    var router: AwakeConfirmationRouter!
    var navigationControllableMock: NavigationControllableMock!
    
    override func setUpWithError() throws {
        navigationControllableMock = NavigationControllableMock()
        let userDefaultsMock = ScheduleUserDefaultsMock()
        
        router = AwakeConfirmationViewRouter(
            navigationControllable: navigationControllableMock,
            userDefaults: userDefaultsMock
        )
    }

    override func tearDownWithError() throws {
        navigationControllableMock = nil
        router = nil
    }

    func testNavigateToSchedule() {
        let channel = Channel(id: "SOME_ID", isPublic: false, text: "SOME_CHANNEL_NAME")
        let message = Message(imageName: "SOME_IMAGE_NAME", imageUrl: "SOME_IMAGE_URL", bodyText: "SOME_BODY_TEXT", channel: channel)
        let schedule = Schedule(message: message, awakeConfirmationTime: Current.now(), scheduledMessageId: "SOME_ID")
        router.navigateToSchedule(with: schedule, isPostMessageSent: .confirmed)
        
        XCTAssertTrue(navigationControllableMock?.pushViewControllerCalledWithArgs?.viewController is ScheduleViewController)
        XCTAssertEqual(navigationControllableMock?.pushViewControllerCalledWithArgs?.animated, true)
        XCTAssertEqual(navigationControllableMock?.viewControllers.count, 1)
    }

}
