//
//  OnboardingRouterTests.swift
//  DozyTests
//
//  Created by Andrew Daniel on 12/30/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

@testable import Dozy
import XCTest
import SwiftUI

class OnboardingRouterTests: XCTestCase {

    private var router: OnboardingRouter!
    private var navigationControllableMock: NavigationControllableMock!
    private var messageFormViewBuilderMock: MessageFormViewBuilderMock!
    
    override func setUpWithError() throws {
        navigationControllableMock = NavigationControllableMock()
        messageFormViewBuilderMock = MessageFormViewBuilderMock()
        
        router = OnboardingViewRouter(navigationControllable: navigationControllableMock, messageFormViewBuilder: messageFormViewBuilderMock)
    }

    override func tearDownWithError() throws {
        navigationControllableMock = nil
        router = nil
    }
    
    func testDismissMessageForm() {
        router.presentMessageForm()
        router.dismissMessageForm(completion: {})
        
        XCTAssertEqual(messageFormViewBuilderMock.builtViewController?.dismissCalledWithArgs, true)
    }
    
    func testNavigateToSchedule() {
        let channel = Channel(id: "SOME_CHANNEL_ID", isPublic: true, text: "SOME_TEXT")
        let message = Message(imageName: nil, imageUrl: nil, bodyText: "SOME_BODY_TEXT", channel: channel)
        let schedule = Schedule(message: message, awakeConfirmationTime: Current.now(), scheduledMessageId: nil)
        router.navigateToSchedule(schedule: schedule, userDefaults: ScheduleUserDefaultsMock())
        
        XCTAssertTrue(navigationControllableMock.pushViewControllerCalledWithArgs?.viewController is ScheduleViewController)
        XCTAssertEqual(navigationControllableMock.pushViewControllerCalledWithArgs?.animated, true)
    }

}

class OnboardingRouterPresentTests: XCTestCase {
    
    private var router: OnboardingRouter!
    private var navigationControllableMock: NavigationControllableMock!
    
    override func setUpWithError() throws {
        navigationControllableMock = NavigationControllableMock()
        
        let channel = Channel(id: "SOME_CHANNEL_ID", isPublic: true, text: "SOME_TEXT")
        let message = Message(imageName: nil, imageUrl: nil, bodyText: "SOME_BODY_TEXT", channel: channel)
        
        router = OnboardingViewRouter(
            navigationControllable: navigationControllableMock,
            messageFormViewBuilder: MessageFormViewBuilder(message: message, delegate: MessageFormDelegateMock())
        )
    }

    override func tearDownWithError() throws {
        navigationControllableMock = nil
        router = nil
    }
    
    func testPresentMessageForm() {
        router.presentMessageForm()
        
        XCTAssertTrue(navigationControllableMock.presentCalledWithArgs?.viewController is UIHostingController<MessageFormView>)
        XCTAssertEqual(navigationControllableMock.presentCalledWithArgs?.animated, true)
    }
    
}

private class MessageFormViewBuilderMock: ViewControllerBuilder {
    
    class MessageFormViewControllerMock: UIViewController {
        var dismissCalledWithArgs: Bool?
        override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
            dismissCalledWithArgs = flag
            completion?()
        }
    }
    
    var builtViewController: MessageFormViewControllerMock?
    func buildViewController() -> UIViewController {
        let viewController = MessageFormViewControllerMock()
        builtViewController = viewController
        return viewController
    }
    
}
