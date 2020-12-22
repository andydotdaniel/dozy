//
//  SchedulePresenterTimerTests.swift
//  DozyTests
//
//  Created by Andrew Daniel on 8/22/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

@testable import Dozy
import XCTest

class SchedulePresenterTimerTests: XCTestCase {

    var presenter: SchedulePresenter!
    var viewModel: ScheduleViewModel!
    
    private func setupPresenter(timerActive: Bool) {
        let channel = Channel(id: "SOME_CHANNEL_ID", isPublic: true, text: "SOME_CHANNEL_NAME")
        let message = Message(image: nil, bodyText: "SOME_BODY_TEXT", channel: channel)
        let scheduledMessageId = timerActive ? "SOME_MESSAGE_ID" : nil
        let schedule = Schedule(message: message, awakeConfirmationTime: Date(), scheduledMessageId: scheduledMessageId)
        viewModel = ScheduleViewModel(schedule: schedule)
        
        let userDefaultsMock = ScheduleUserDefaultsMock()
        
        let urlSessionMock = URLSessionMock()
        let networkService = NetworkService(urlSession: urlSessionMock)
        let keychainMock = KeychainMock()
        
        presenter = SchedulePresenter(schedule: schedule, isPostMessageSent: false, viewModel: viewModel, userDefaults: userDefaultsMock, networkService: networkService, keychain: keychainMock, navigationControllable: NavigationControllableMock(), awakeConfirmationTimer: TimerMock())
    }
    
    func testAwakeConfirmationCardTextWhenTimerEnabled() throws {
        self.setupPresenter(timerActive: true)
        
        XCTAssertEqual(viewModel.awakeConfirmationCard.preMutableText, "Open the app in ")
        XCTAssertEqual(viewModel.awakeConfirmationCard.postMutableText, " or your sleepyhead message gets sent.")
    }
    
    func testAwakeConfirmationCardText() throws {
        self.setupPresenter(timerActive: false)
        
        XCTAssertEqual(viewModel.awakeConfirmationCard.preMutableText, "Awake confirmation timer is currently disabled.")
        XCTAssertEqual(viewModel.awakeConfirmationCard.mutableText, "")
        XCTAssertEqual(viewModel.awakeConfirmationCard.postMutableText, "")
    }

}
