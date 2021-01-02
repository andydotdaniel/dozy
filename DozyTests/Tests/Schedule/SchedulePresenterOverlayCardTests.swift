//
//  SchedulePresenterOverlayCardTests.swift
//  DozyTests
//
//  Created by Andrew Daniel on 12/22/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import XCTest
@testable import Dozy

class SchedulePresenterOverlayCardTests: XCTestCase {

    var presenter: SchedulePresenter!
    var viewModel: ScheduleViewModel!
    var schedule: Schedule!
    
    override func tearDownWithError() throws {
        viewModel = nil
        presenter = nil
    }
    
    private func setupPresenter(isPostMessageSent: Bool, isScheduleActive: Bool) {
        let channel = Channel(id: "SOME_CHANNEL_ID", isPublic: true, text: "SOME_CHANNEL_NAME")
        let message = Message(imageName: nil, imageUrl: nil, bodyText: "SOME_BODY_TEXT", channel: channel)
        schedule = Schedule(message: message, awakeConfirmationTime: Current.now(), scheduledMessageId: isScheduleActive ? "SOME_MESSAGE_ID": nil)
        viewModel = ScheduleViewModel(schedule: schedule)
        
        let userDefaultsMock = ScheduleUserDefaultsMock()
        
        let urlSessionMock = URLSessionMock()
        let networkService = NetworkService(urlSession: urlSessionMock)
        let keychainMock = KeychainMock()
        
        presenter = SchedulePresenter(schedule: schedule, isPostMessageSent: isPostMessageSent, viewModel: viewModel, userDefaults: userDefaultsMock, networkService: networkService, keychain: keychainMock, navigationControllable: NavigationControllableMock(), awakeConfirmationTimer: TimerMock(), userNotificationCenter: UserNotificationCenterMock())
    }
    
    func testShowOverlayCardOnInit() {
        setupPresenter(isPostMessageSent: true, isScheduleActive: true)
        XCTAssertTrue(viewModel.isShowingOverlayCard)
    }
    
    func testDismissOverlayCardButtonTap() {
        setupPresenter(isPostMessageSent: true, isScheduleActive: true)
        presenter.onOverlayCardDismissButtonTapped()
        XCTAssertFalse(viewModel.isShowingOverlayCard)
    }
    
    func testShowOverlayCardWhenEnterForeground() {
        setupPresenter(isPostMessageSent: false, isScheduleActive: true)
        
        Current.now = { self.schedule.sleepyheadMessagePostTime.addingTimeInterval(1) }
        
        expectation(
            forNotification: SceneNotification.willEnterForeground,
            object: nil,
            handler: nil
        )
        NotificationCenter.default.post(name: SceneNotification.willEnterForeground, object: nil)
        
        XCTAssertTrue(viewModel.isShowingOverlayCard)
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testDoNothingWhenEnterForegroundForInactiveSchedule() {
        setupPresenter(isPostMessageSent: false, isScheduleActive: false)
        
        Current.now = { self.schedule.sleepyheadMessagePostTime.addingTimeInterval(1) }
        
        expectation(
            forNotification: SceneNotification.willEnterForeground,
            object: nil,
            handler: nil
        )
        NotificationCenter.default.post(name: SceneNotification.willEnterForeground, object: nil)
        
        XCTAssertFalse(viewModel.isShowingOverlayCard)
        
        waitForExpectations(timeout: 5, handler: nil)
    }

}
