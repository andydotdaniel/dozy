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
    private var viewModel: OnboardingViewModel!
    
    private var navigationControllableMock: NavigationControllableMock!
    
    override func setUpWithError() throws {
        viewModel = OnboardingViewModel()
        userDefaultsMock = ScheduleUserDefaultsMock()
        navigationControllableMock = NavigationControllableMock()
        
        presenter = OnboardingPresenter(viewModel: viewModel, userDefaults: userDefaultsMock, navigationControllable: navigationControllableMock)
    }

    override func tearDownWithError() throws {
        userDefaultsMock = nil
        presenter = nil
    }

    func testOnMessageSaved() throws {
        let channel = Channel(id: "SOME_ID", isPublic: false, text: "SOME_TEXT")
        let message = Message(image: nil, imageUrl: nil, bodyText: "SOME_BODY_TEXT", channel: channel)
        presenter.onMessageSaved(message)
        
        XCTAssertEqual(userDefaultsMock.scheduleSaved?.message, message)
        XCTAssertNil(userDefaultsMock.scheduleSaved?.scheduledMessageId)
        
        XCTAssertTrue(navigationControllableMock.pushViewControllerCalledWithArgs?.viewController is ScheduleViewController)
        XCTAssertEqual(navigationControllableMock.pushViewControllerCalledWithArgs?.animated, false)
        XCTAssertFalse(viewModel.isShowingMessageForm)
    }

}
