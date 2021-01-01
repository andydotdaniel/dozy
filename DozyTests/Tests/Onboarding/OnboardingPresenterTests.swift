//
//  OnboardingPresenterTests.swift
//  DozyTests
//
//  Created by Andrew Daniel on 10/3/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import XCTest
@testable import Dozy

class OnboardingPresenterTests: XCTestCase {

    private var presenter: OnboardingPresenter!
    private var userDefaultsMock: ScheduleUserDefaultsMock!
    private var routerMock: OnboardingRouterMock!
    
    override func setUpWithError() throws {
        userDefaultsMock = ScheduleUserDefaultsMock()
        routerMock = OnboardingRouterMock()
        
        presenter = OnboardingPresenter(userDefaults: userDefaultsMock)
        presenter.router = routerMock
    }

    override func tearDownWithError() throws {
        userDefaultsMock = nil
        presenter = nil
    }
    
    func testDidTapCreateMessageButton() {
        presenter.didTapCreateMessageButton()
        XCTAssertTrue(routerMock.presentMessageFormCalled)
    }

    func testOnMessageSaved() {
        let channel = Channel(id: "SOME_ID", isPublic: false, text: "SOME_TEXT")
        let message = Message(imageName: nil, imageUrl: nil, bodyText: "SOME_BODY_TEXT", channel: channel)
        presenter.onMessageSaved(message)
        
        XCTAssertEqual(userDefaultsMock.scheduleSaved?.message, message)
        XCTAssertNil(userDefaultsMock.scheduleSaved?.scheduledMessageId)
        
        XCTAssertTrue(routerMock.dismissMessageFormCalled)
        
        XCTAssertEqual(routerMock.navigateToScheduleCalledWithArgs?.schedule, userDefaultsMock.scheduleSaved)
        XCTAssertTrue(routerMock.navigateToScheduleCalledWithArgs?.userDefaults === userDefaultsMock)
    }

}

private class OnboardingRouterMock: OnboardingRouter {
    
    var presentMessageFormCalled: Bool = false
    func presentMessageForm() {
        presentMessageFormCalled = true
    }
    
    var dismissMessageFormCalled: Bool = false
    func dismissMessageForm(completion: @escaping (() -> Void)) {
        dismissMessageFormCalled = true
        completion()
    }
    
    var navigateToScheduleCalledWithArgs: (schedule: Schedule, userDefaults: ScheduleUserDefaults)?
    func navigateToSchedule(schedule: Schedule, userDefaults: ScheduleUserDefaults) {
        navigateToScheduleCalledWithArgs = (schedule, userDefaults)
    }
    
}
