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
    
    var navigationControllable: NavigationControllableMock!
    
    var schedule: Schedule!
    
    override func setUpWithError() throws {
        Current = .mock
        
        userDefaultsMock = ScheduleUserDefaultsMock()
        
        keychainMock = KeychainMock()
        keychainMock.dataToLoad = Data("SOME_ACCESS_TOKEN".utf8)
        
        urlSessionMock = URLSessionMock()
        let networkService = NetworkService(urlSession: urlSessionMock)
        
        viewModel = AwakeConfirmationViewModel(countdownActive: true, secondsLeft: 30)
        let message = Message(image: nil, imageUrl: nil, bodyText: "SOME_BODY_TEXT", channel: Channel(id: "SOME_ID", isPublic: false, text: "SOME_TEXT"))
        schedule = Schedule(message: message, awakeConfirmationTime: Date().addingTimeInterval(30), scheduledMessageId: "SOME_ID")
        
        navigationControllable = NavigationControllableMock()
        
        presenter = AwakeConfirmationPresenter(
            viewModel: viewModel,
            networkService: networkService,
            keychain: keychainMock,
            userDefaults: userDefaultsMock,
            savedSchedule: schedule,
            navigationControllable: navigationControllable
        )
    }

    override func tearDownWithError() throws {
        presenter = nil
        Current = World()
    }

    func testOnSliderReachedEnd() throws {
        let channel = Channel(id: "SOME_CHANNEL_ID", isPublic: true, text: "SOME_TEXT")
        let message = Message(image: nil, imageUrl: nil, bodyText: "SOME_MESSAGE_TEXT", channel: channel)
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
        XCTAssertTrue(navigationControllable?.pushViewControllerCalledWithArgs?.viewController is ScheduleViewController)
        XCTAssertEqual(navigationControllable?.pushViewControllerCalledWithArgs?.animated, true)
        XCTAssertEqual(navigationControllable?.viewControllers.count, 1)
    }
    
    func testOnSliderReachedEndNetworkFailure() throws {
        urlSessionMock.results.append(URLSessionMockResult(data: nil, urlResponse: nil, error: URLSessionMock.NetworkError.someError))
        presenter.onSliderReachedEnd()
        
        XCTAssertTrue(viewModel.isShowingError)
        XCTAssertFalse(viewModel.sliderHasReachedEnd)
    }
    
    func testWillEnterForegroundWhenSecondsLeftGreaterThanOne() {
        let updatedTime = self.schedule.sleepyheadMessagePostTime.addingTimeInterval(-30)
        Current.now = { updatedTime }
        
        expectation(
            forNotification: SceneNotification.willEnterForeground,
            object: nil,
            handler: nil
        )

        NotificationCenter.default.post(name: SceneNotification.willEnterForeground, object: nil)
        XCTAssertEqual(viewModel.secondsLeft, Int(schedule.sleepyheadMessagePostTime.timeIntervalSince(updatedTime)))
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testWillEnterForegroundWhenSecondsLeftLessThanOne() {
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
        XCTAssertTrue(navigationControllable?.pushViewControllerCalledWithArgs?.viewController is ScheduleViewController)
        XCTAssertEqual(navigationControllable?.pushViewControllerCalledWithArgs?.animated, true)
        XCTAssertEqual(navigationControllable?.viewControllers.count, 1)
        
        waitForExpectations(timeout: 5, handler: nil)
    }

}
