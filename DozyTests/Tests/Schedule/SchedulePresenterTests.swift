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
    
    override func setUpWithError() throws {
        Current = .mock
        
        let channel = Channel(id: "SOME_CHANNEL_ID", isPublic: true, text: "SOME_CHANNEL_NAME")
        let message = Message(image: nil, bodyText: "SOME_BODY_TEXT", channel: channel)
        schedule = Schedule(message: message, awakeConfirmationTime: Date(), scheduledMessageId: nil)
        viewModel = ScheduleViewModel(schedule: schedule)
        
        userDefaultsMock = ScheduleUserDefaultsMock()
        
        urlSessionMock = URLSessionMock()
        let networkService = NetworkService(urlSession: urlSessionMock)
        keychainMock = KeychainMock()
        
        presenter = SchedulePresenter(schedule: schedule, viewModel: viewModel, userDefaults: userDefaultsMock, networkService: networkService, keychain: keychainMock)
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
        let message = Message(image: nil, bodyText: "SOME_DIFFERENT_BODY_TEXT", channel: channel)
        presenter.onMessageSaved(message)
        
        XCTAssertEqual(self.viewModel.messageCard.bodyText, message.bodyText)
        
        let expectedImage = message.image.map { UIImage(data: $0) } ?? nil
        XCTAssertEqual(self.viewModel.messageCard.image, expectedImage)
        
        XCTAssertEqual(self.viewModel.messageCard.channel.isPublic, channel.isPublic)
        XCTAssertEqual(self.viewModel.messageCard.channel.text, channel.text)
        
        XCTAssertEqual(self.viewModel.messageCard.actionButtonTitle, "Edit")
        
        let expectedSchedule = Schedule(message: message, awakeConfirmationTime: schedule.awakeConfirmationTime, scheduledMessageId: nil)
        XCTAssertEqual(userDefaultsMock.scheduleSaved, expectedSchedule)
    }
    
    func testOnTimePickerDoneButtonTapped() {
        let dateAdded = Current.now().addingTimeInterval(2700)
        self.viewModel.awakeConfirmationCard.timePickerDate = dateAdded
        
        self.presenter.onTimePickerDoneButtonTapped()
        
        XCTAssertEqual(self.userDefaultsMock.scheduleSaved!.awakeConfirmationTime.timeIntervalSinceReferenceDate, dateAdded.timeIntervalSinceReferenceDate, accuracy: 0.001)
        
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

}
