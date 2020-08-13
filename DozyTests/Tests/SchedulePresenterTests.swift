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
    
    override func setUpWithError() throws {
        let channel = Channel(id: "SOME_CHANNEL_ID", isPublic: true, text: "SOME_CHANNEL_NAME")
        let message = Message(image: nil, bodyText: "SOME_BODY_TEXT", channel: channel)
        schedule = Schedule(message: message, awakeConfirmationTime: Date(), isActive: true)
        viewModel = ScheduleViewModel(schedule: schedule)
        
        userDefaultsMock = ScheduleUserDefaultsMock()
        
        presenter = SchedulePresenter(schedule: schedule, viewModel: viewModel, userDefaults: userDefaultsMock)
    }

    override func tearDownWithError() throws {
        presenter = nil
    }

    func testOnSwitchPositionChanged() throws {
        presenter.onSwitchPositionChanged(position: .on)
        XCTAssertEqual(viewModel.state, .active)
        
        presenter.onSwitchPositionChanged(position: .off)
        XCTAssertEqual(viewModel.state, .inactive)
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
        
        
        let expectedSchedule = Schedule(message: message, awakeConfirmationTime: schedule.awakeConfirmationTime, isActive: schedule.isActive)
        XCTAssertEqual(userDefaultsMock.scheduleSaved, expectedSchedule)
    }

}
