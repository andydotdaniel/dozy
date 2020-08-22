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
        let schedule = Schedule(message: message, awakeConfirmationTime: Date(), isActive: timerActive)
        viewModel = ScheduleViewModel(schedule: schedule)
        
        let userDefaultsMock = ScheduleUserDefaultsMock()
        
        presenter = SchedulePresenter(schedule: schedule, viewModel: viewModel, userDefaults: userDefaultsMock)
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
