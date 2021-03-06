//
//  SchedulePresenterTests.swift
//  DozyTests
//
//  Created by Andrew Daniel on 8/12/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

@testable import Dozy
import XCTest

class SchedulePresenterTests: XCTestCase {

    var presenter: SchedulePresenter!
    var viewModel: ScheduleViewModel!
    var schedule: Schedule!
    
    var userDefaultsMock: ScheduleUserDefaultsMock!
    var urlSessionMock: URLSessionMock!
    var keychainMock: KeychainMock!
    var userNotificationCenterMock: UserNotificationCenterMock!
    
    var navigationControllable: NavigationControllableMock!
    
    var timerMock: TimerMock!
    
    override func setUpWithError() throws {
        Current = .mock
        let now = Date()
        Current.now = { now }
        
        let channel = Channel(id: "SOME_CHANNEL_ID", isPublic: true, text: "SOME_CHANNEL_NAME")
        let message = Message(imageName: nil, imageUrl: nil, bodyText: "SOME_BODY_TEXT", channel: channel)
        schedule = Schedule(message: message, awakeConfirmationTime: Current.now().addingTimeInterval(5), scheduledMessageId: "SOME_PRESCHEDULED_MESSAGE_ID")
        viewModel = ScheduleViewModel(schedule: schedule)
        
        userDefaultsMock = ScheduleUserDefaultsMock()
        
        urlSessionMock = URLSessionMock()
        let networkService = NetworkService(urlSession: urlSessionMock)
        keychainMock = KeychainMock()
        keychainMock.dataToLoad = Data("SOME_ACCESS_TOKEN".utf8)
        
        navigationControllable = NavigationControllableMock()
        
        timerMock = TimerMock()
        
        userNotificationCenterMock = UserNotificationCenterMock()
        
        presenter = SchedulePresenter(
            schedule: schedule,
            isPostMessageSent: .notSent,
            viewModel: viewModel,
            userDefaults: userDefaultsMock,
            networkService: networkService,
            keychain: keychainMock,
            navigationControllable: navigationControllable,
            awakeConfirmationTimer: timerMock,
            userNotificationCenter: userNotificationCenterMock
        )
    }

    override func tearDownWithError() throws {
        presenter = nil
        Current = World()
    }
    
    func testOnMessageActionButtonTapped() throws {
        presenter.onMessageActionButtonTapped()
        XCTAssertTrue(viewModel.isShowingMessageForm)
    }
    
    func testOnMessageSaved() throws {
        let channel = Channel(id: "SOME_OTHER_CHANNEL_ID", isPublic: false, text: "SOME_OTHER_CHANNEL_NAME")
        let message = Message(imageName: nil, imageUrl: nil, bodyText: "SOME_DIFFERENT_BODY_TEXT", channel: channel)
        presenter.onMessageSaved(message)
        
        XCTAssertEqual(self.viewModel.messageCard.bodyText, message.bodyText)
        
        XCTAssertEqual(self.viewModel.messageCard.image, nil)
        
        XCTAssertEqual(self.viewModel.messageCard.channel.isPublic, channel.isPublic)
        XCTAssertEqual(self.viewModel.messageCard.channel.text, channel.text)
        
        XCTAssertEqual(self.viewModel.messageCard.actionButtonTitle, "Edit")
        
        let expectedSchedule = Schedule(message: message, awakeConfirmationTime: schedule.awakeConfirmationTime, scheduledMessageId: schedule.scheduledMessageId)
        XCTAssertEqual(userDefaultsMock.scheduleSaved, expectedSchedule)
    }
    
    func testOnTimePickerDoneButtonTapped() {
        let dateAdded = Current.now().addingTimeInterval(2700)
        self.viewModel.awakeConfirmationCard.timePickerDate = dateAdded
        
        self.presenter.onTimePickerDoneButtonTapped()
        
        let nowSecondsComponent = TimeInterval(Calendar.current.dateComponents([.second], from: Current.now()).second ?? 0)
        let expectedAwakeConfirmationTime = dateAdded.addingTimeInterval(-nowSecondsComponent).timeIntervalSinceReferenceDate
        XCTAssertEqual(self.userDefaultsMock.scheduleSaved!.awakeConfirmationTime.timeIntervalSinceReferenceDate, expectedAwakeConfirmationTime, accuracy: 0.001)
        
        XCTAssertEqual(self.userDefaultsMock.scheduleSaved?.awakeConfirmationDateText, viewModel.awakeConfirmationCard.titleText)
        XCTAssertEqual(self.userDefaultsMock.scheduleSaved?.awakeConfirmationTimeText, viewModel.awakeConfirmationCard.subtitleText)
    }
    
    func testOnTimePickerDoneButtonTappedForNextDay() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-mm-dd HH:mm:ss"
        Current.now = { dateFormatter.date(from: "2020-10-01 10:30:00")! }
        
        let updatedTime = dateFormatter.date(from: "2020-10-02 06:30:00")!
        self.viewModel.awakeConfirmationCard.timePickerDate = updatedTime
        
        self.presenter.onTimePickerDoneButtonTapped()
        
        XCTAssertEqual(self.userDefaultsMock.scheduleSaved!.awakeConfirmationTime.timeIntervalSinceReferenceDate, updatedTime.timeIntervalSinceReferenceDate, accuracy: 0.001)
        
        XCTAssertEqual(self.userDefaultsMock.scheduleSaved?.awakeConfirmationDateText, viewModel.awakeConfirmationCard.titleText)
        XCTAssertEqual(self.userDefaultsMock.scheduleSaved?.awakeConfirmationTimeText, viewModel.awakeConfirmationCard.subtitleText)
    }
    
    func testOnProfileButtonTapped() {
        self.presenter.onProfileIconTapped()
        
        XCTAssertEqual(self.navigationControllable.pushViewControllerCalledWithArgs?.animated, true)
        XCTAssertTrue(self.navigationControllable.pushViewControllerCalledWithArgs?.viewController is ProfileViewController)
    }
    
    func testOnSwitchPositionChangedTriggeredForInvalidTime() {
        self.viewModel.state = .inactive
        Current.now = { self.schedule.awakeConfirmationTime.addingTimeInterval(1) }
        self.presenter.onSwitchPositionChangedTriggered()
        
        XCTAssertTrue(self.viewModel.errorToastIsShowing)
    }
    
    func testOnSwitchPositionChangedTriggeredForActiveSchedule() throws {
        self.viewModel.state = .inactive
        self.urlSessionMock.results.append(try JSONLoader.load(fileName: "ScheduledMessage"))
        
        Current.now = { self.schedule.awakeConfirmationTime.addingTimeInterval(-1) }
        self.presenter.onSwitchPositionChangedTriggered()
        
        XCTAssertEqual(self.viewModel.state, .active)
        XCTAssertEqual(self.viewModel.switchPosition.position, .on)
        XCTAssertEqual(self.viewModel.switchPosition.isLoading, false)
        XCTAssertEqual(self.userDefaultsMock.scheduleSaved?.scheduledMessageId, "SOME_SCHEDULED_MESSAGE_ID")
        XCTAssertEqual(self.userNotificationCenterMock.requestIdentifierAdded, pushNotificationIdentifier)
    }
    
    func testOnSwitchPositionChangedTriggeredForInactiveScheduleBeforeLeadTime() {
        self.viewModel.state = .active
        self.urlSessionMock.results.append(.init(data: Data(), urlResponse: nil, error: nil))
        
        let leadTimeInSeconds: TimeInterval = 15 * 60
        Current.now = { self.schedule.awakeConfirmationTime.addingTimeInterval(-(leadTimeInSeconds + 1)) }
        self.presenter.onSwitchPositionChangedTriggered()
        
        XCTAssertEqual(self.viewModel.state, .inactive)
        XCTAssertEqual(self.viewModel.switchPosition.position, .off)
        XCTAssertEqual(self.viewModel.switchPosition.isLoading, false)
        XCTAssertNil(self.userDefaultsMock.scheduleSaved?.scheduledMessageId)
        XCTAssertEqual(self.userNotificationCenterMock.identifiersRemoved, [pushNotificationIdentifier])
    }
    
    func testOnSwitchPositionChangedTriggeredForInactiveScheduleAfterLeadTime() {
        self.viewModel.state = .active
        
        Current.now = { self.schedule.awakeConfirmationTime.addingTimeInterval(-1) }
        self.presenter.onSwitchPositionChangedTriggered()
        
        XCTAssertEqual(self.viewModel.state, .active)
        XCTAssertTrue(self.viewModel.errorToastIsShowing)
        XCTAssertEqual(self.viewModel.errorToastText, "Cannot disable when timer is under 15 minutes.")
    }
    
    func testWillEnterForegroundNavigatesToAwakeConfirmation() {
        Current.now = { self.schedule.awakeConfirmationTime.addingTimeInterval(1) }
        
        expectation(
            forNotification: SceneNotification.willEnterForeground,
            object: nil,
            handler: nil
        )

        NotificationCenter.default.post(name: SceneNotification.willEnterForeground, object: nil)
        
        XCTAssertEqual(navigationControllable?.pushViewControllerCalledWithArgs?.animated, true)
        XCTAssertTrue(navigationControllable?.pushViewControllerCalledWithArgs?.viewController is AwakeConfirmationViewController)
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testWillEnterForegroundUpdatesTimerText() {
        func secondsToHoursMinutesSeconds (seconds : Int) -> (hours: Int, minutes: Int, seconds: Int) {
            return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
        }
        
        Current.now = { self.schedule.awakeConfirmationTime.addingTimeInterval(-60) }
        
        expectation(
            forNotification: SceneNotification.willEnterForeground,
            object: nil,
            handler: nil
        )

        NotificationCenter.default.post(name: SceneNotification.willEnterForeground, object: nil)
        
        timerMock.actionBlock?()
        
        let time = secondsToHoursMinutesSeconds(seconds: Int(self.schedule.awakeConfirmationTime.timeIntervalSince(Current.now())))
        let hoursString = time.hours < 10 ? "0\(time.hours)" : "\(time.hours)"
        let minutesString = time.minutes < 10 ? "0\(time.minutes)" : "\(time.minutes)"
        let secondsString = time.seconds < 10 ? "0\(time.seconds)" : "\(time.seconds)"
        
        let expectedTimerText = "\(hoursString):\(minutesString):\(secondsString)"
        XCTAssertEqual(viewModel.awakeConfirmationCard.mutableText, expectedTimerText)
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testAwakeConfirmationTimerReachedEndNavigatesToAwakeConfirmationTimer() {
        let secondsToAwakeConfirmation: Int = Int(schedule.awakeConfirmationTime.timeIntervalSince(Current.now()))
        
        for _ in 0...secondsToAwakeConfirmation {
            timerMock.actionBlock?()
        }
        
        XCTAssertEqual(navigationControllable?.pushViewControllerCalledWithArgs?.animated, true)
        XCTAssertTrue(navigationControllable?.pushViewControllerCalledWithArgs?.viewController is AwakeConfirmationViewController)
        XCTAssertTrue(timerMock.stopTimerCalled)
    }
    
    func testChangeAwakeConfirmationTimeTapWhenDisabled() {
        viewModel.state = .inactive
        
        presenter.onChangeAwakeConfirmationTimeTapped()
        XCTAssertTrue(viewModel.awakeConfirmationCard.isShowingTimePicker)
    }
    
    func testChangeAwakeConfirmationTimeTapWhenEnabled() {
        viewModel.state = .active
        
        presenter.onChangeAwakeConfirmationTimeTapped()
        XCTAssertTrue(viewModel.errorToastIsShowing)
        XCTAssertEqual(viewModel.errorToastText, "Cannot change time when timer is enabled.")
    }
    
    func testShowErrorWhenSendingScheduledMessageRequest() {
        self.viewModel.state = .inactive
        self.urlSessionMock.results.append(.init(data: nil, urlResponse: nil, error: URLSessionMock.NetworkError.someError))
        
        self.presenter.onSwitchPositionChangedTriggered()
            
        XCTAssertEqual(viewModel.state, .inactive)
        XCTAssertTrue(viewModel.errorToastIsShowing)
        XCTAssertEqual(viewModel.errorToastText, "Oops, something happened. Please try again.")
    }
    
    func testShowErrorWhenSendingDeleteScheduledMessageRequest() {
        self.viewModel.state = .active
        self.urlSessionMock.results.append(.init(data: nil, urlResponse: nil, error: URLSessionMock.NetworkError.someError))
        
        let leadTimeInSeconds: TimeInterval = 15 * 60
        Current.now = { self.schedule.awakeConfirmationTime.addingTimeInterval(-(leadTimeInSeconds + 1)) }
        self.presenter.onSwitchPositionChangedTriggered()
            
        XCTAssertEqual(viewModel.state, .active)
        XCTAssertTrue(viewModel.errorToastIsShowing)
        XCTAssertEqual(viewModel.errorToastText, "Oops, something happened. Please try again.")
    }
    
    func testOnMessageFormCancelled() {
        self.viewModel.isShowingMessageForm = true
        
        presenter.onMessageFormCancelled()
        XCTAssertFalse(self.viewModel.isShowingMessageForm)
    }

}
