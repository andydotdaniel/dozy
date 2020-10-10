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
    
    var userDefaultsMock: ScheduleUserDefaultsMock!
    var urlSessionMock: URLSessionMock!
    var keychainMock: KeychainMock!
    
    override func setUpWithError() throws {
        Current = .mock
        
        userDefaultsMock = ScheduleUserDefaultsMock()
        
        keychainMock = KeychainMock()
        keychainMock.dataToLoad = Data("SOME_ACCESS_TOKEN".utf8)
        
        urlSessionMock = URLSessionMock()
        let networkService = NetworkService(urlSession: urlSessionMock)
        
        presenter = AwakeConfirmationPresenter(
            networkService: networkService,
            keychain: keychainMock,
            userDefaults: userDefaultsMock
        )
    }

    override func tearDownWithError() throws {
        presenter = nil
        Current = World()
    }

    func testOnSliderReachedEnd() throws {
        let channel = Channel(id: "SOME_CHANNEL_ID", isPublic: true, text: "SOME_TEXT")
        let message = Message(image: nil, bodyText: "SOME_MESSAGE_TEXT", channel: channel)
        userDefaultsMock.scheduleSaved = Schedule(
            message: message,
            awakeConfirmationTime: Date(),
            scheduledMessageId: "SOME_SCHEDULED_MESSAGE_ID"
        )
        
        let jsonDictionary: [String: Any] = ["ok": true]
        let data = try JSONSerialization.data(withJSONObject: jsonDictionary, options: .prettyPrinted)
        urlSessionMock.result = URLSessionMockResult(data: data, urlResponse: nil, error: nil)
        
        presenter.onSliderReachedEnd()
        
        XCTAssertNotNil(userDefaultsMock.scheduleSaved)
        XCTAssertNil(userDefaultsMock.scheduleSaved?.scheduledMessageId)
    }

}
