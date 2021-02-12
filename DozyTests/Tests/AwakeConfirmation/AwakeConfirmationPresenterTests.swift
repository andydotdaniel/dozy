//
//  AwakeConfirmationPresenterTests.swift
//  DozyTests
//
//  Created by Andrew Daniel on 10/10/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

@testable import Dozy
import XCTest

class AwakeConfirmationPresenterTests: XCTestCase {

    var presenter: AwakeConfirmationPresenter!
    var viewModel: AwakeConfirmationViewModel!
    
    var userDefaultsMock: ScheduleUserDefaultsMock!
    var urlSessionMock: URLSessionMock!
    var keychainMock: KeychainMock!
    var timerMock: TimerMock!
    
    var routerMock: AwakeConfirmationRouterMock!
    
    var schedule: Schedule!
    
    override func setUpWithError() throws {
        Current = .mock
        
        userDefaultsMock = ScheduleUserDefaultsMock()
        
        keychainMock = KeychainMock()
        keychainMock.dataToLoad = Data("SOME_ACCESS_TOKEN".utf8)
        
        urlSessionMock = URLSessionMock()
        let networkService = NetworkService(urlSession: urlSessionMock)
        
        viewModel = AwakeConfirmationViewModel(countdownActive: true, secondsLeft: 30)
        let message = Message(imageName: nil, imageUrl: nil, bodyText: "SOME_BODY_TEXT", channel: Channel(id: "SOME_ID", isPublic: false, text: "SOME_TEXT"))
        schedule = Schedule(message: message, awakeConfirmationTime: Date().addingTimeInterval(30), scheduledMessageId: "SOME_ID")
        
        routerMock = AwakeConfirmationRouterMock()
        
        timerMock = TimerMock()
        
        presenter = AwakeConfirmationPresenter(
            viewModel: viewModel,
            networkService: networkService,
            keychain: keychainMock,
            userDefaults: userDefaultsMock,
            savedSchedule: schedule,
            router: routerMock,
            secondsLeftTimer: timerMock
        )
    }

    override func tearDownWithError() throws {
        presenter = nil
        Current = World()
    }
    
    func testStartTimer() {
        XCTAssertNotNil(timerMock.actionBlock)
    }

    func testOnSliderReachedEnd() throws {
        let channel = Channel(id: "SOME_CHANNEL_ID", isPublic: true, text: "SOME_TEXT")
        let message = Message(imageName: nil, imageUrl: nil, bodyText: "SOME_MESSAGE_TEXT", channel: channel)
        userDefaultsMock.scheduleSaved = Schedule(
            message: message,
            awakeConfirmationTime: Date(),
            scheduledMessageId: "SOME_SCHEDULED_MESSAGE_ID"
        )
        
        let jsonDictionary: [String: Any] = ["ok": true]
        let data = try JSONSerialization.data(withJSONObject: jsonDictionary, options: .prettyPrinted)
        urlSessionMock.results.append(URLSessionMockResult(data: data, urlResponse: nil, error: nil))
        
        presenter.onSliderReachedEnd()
        
        XCTAssertNotNil(userDefaultsMock.scheduleSaved)
        XCTAssertNil(userDefaultsMock.scheduleSaved?.scheduledMessageId)
        XCTAssertTrue(timerMock.stopTimerCalled)
        XCTAssertEqual(routerMock.navigateToScheduleCalledWithArgs?.schedule, userDefaultsMock.scheduleSaved)
        XCTAssertEqual(routerMock.navigateToScheduleCalledWithArgs?.isPostMessageSent, .notSent)
    }
    
    func testOnSliderReachedEndNetworkFailure() throws {
        urlSessionMock.results.append(URLSessionMockResult(data: nil, urlResponse: nil, error: URLSessionMock.NetworkError.someError))
        presenter.onSliderReachedEnd()
        
        XCTAssertTrue(viewModel.isShowingError)
        XCTAssertFalse(viewModel.sliderHasReachedEnd)
    }
    
    func testWillEnterForegroundWhenSecondsLeftGreaterThanOne() {
        let updatedTime = self.schedule.delayedAwakeConfirmationTime.addingTimeInterval(-30)
        Current.now = { updatedTime }
        
        expectation(
            forNotification: SceneNotification.willEnterForeground,
            object: nil,
            handler: nil
        )

        NotificationCenter.default.post(name: SceneNotification.willEnterForeground, object: nil)
        XCTAssertEqual(viewModel.secondsLeft, Int(schedule.delayedAwakeConfirmationTime.timeIntervalSince(updatedTime)))
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testWillEnterForegroundWhenSecondsLeftLessThanOne() {
        let updatedTime = self.schedule.delayedAwakeConfirmationTime.addingTimeInterval(1)
        Current.now = { updatedTime }
        
        expectation(
            forNotification: SceneNotification.willEnterForeground,
            object: nil,
            handler: nil
        )

        NotificationCenter.default.post(name: SceneNotification.willEnterForeground, object: nil)
        
        XCTAssertNotNil(userDefaultsMock.scheduleSaved)
        XCTAssertNil(userDefaultsMock.scheduleSaved?.scheduledMessageId)
        XCTAssertTrue(timerMock.stopTimerCalled)
        XCTAssertEqual(routerMock.navigateToScheduleCalledWithArgs?.schedule, userDefaultsMock.scheduleSaved)
        XCTAssertEqual(routerMock.navigateToScheduleCalledWithArgs?.isPostMessageSent, .confirmed)
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testWillEnterForegroundWhenAfterSleepyheadMessagePostTime() {
        let updatedTime = self.schedule.sleepyheadMessagePostTime.addingTimeInterval(1)
        Current.now = { updatedTime }
        
        expectation(
            forNotification: SceneNotification.willEnterForeground,
            object: nil,
            handler: nil
        )

        NotificationCenter.default.post(name: SceneNotification.willEnterForeground, object: nil)
        
        XCTAssertNotNil(userDefaultsMock.scheduleSaved)
        XCTAssertNil(userDefaultsMock.scheduleSaved?.scheduledMessageId)
        XCTAssertTrue(timerMock.stopTimerCalled)
        XCTAssertEqual(routerMock.navigateToScheduleCalledWithArgs?.schedule, userDefaultsMock.scheduleSaved)
        XCTAssertEqual(routerMock.navigateToScheduleCalledWithArgs?.isPostMessageSent, .sent)
        
        waitForExpectations(timeout: 5, handler: nil)
    }

}

class AwakeConfirmationRouterMock: AwakeConfirmationRouter {
    
    var navigateToScheduleCalledWithArgs: (schedule: Schedule, isPostMessageSent: ScheduledMessageStatus)?
    func navigateToSchedule(with schedule: Schedule, isPostMessageSent: ScheduledMessageStatus) {
        navigateToScheduleCalledWithArgs = (schedule, isPostMessageSent)
    }
    
}
