//
//  ProfilePresenterProfileUnfetchedTests.swift
//  DozyTests
//
//  Created by Andrew Daniel on 12/15/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

@testable import Dozy
import XCTest

class ProfilePresenterProfileUnfetchedTests: XCTestCase {
    
    private var presenter: ProfilePresenter!
    private var viewModel: ProfileViewModel!
    
    private var navigationControllable: NavigationControllableMock!
    
    private var profileUserDefaultsMock: ProfileUserDefaultsMock!
    private var scheduleUserDefaultsMock: ScheduleUserDefaultsMock!
    
    private var urlSessionMock: URLSessionMock!

    private final func setupPresenter(with result: URLSessionMockResult) {
        viewModel = ProfileViewModel()
        
        navigationControllable = NavigationControllableMock()
        
        scheduleUserDefaultsMock = ScheduleUserDefaultsMock()
        profileUserDefaultsMock = ProfileUserDefaultsMock()
        
        urlSessionMock = URLSessionMock()
        urlSessionMock.result = result
        
        let keychainMock = KeychainMock()
        keychainMock.dataToLoad = Data("SOME_ACCESS_TOKEN".utf8)
        
        presenter = ProfilePresenter(
            profileUserDefaults: profileUserDefaultsMock,
            scheduleUserDefaults: scheduleUserDefaultsMock,
            viewModel: viewModel,
            networkService: NetworkService(urlSession: urlSessionMock),
            keychain: keychainMock,
            navigationControllable: navigationControllable
        )
    }
    
    override func setUpWithError() throws {
        Current = .mock
    }

    override func tearDownWithError() throws {
        self.presenter = nil
        self.navigationControllable = nil
        self.profileUserDefaultsMock = nil
        self.scheduleUserDefaultsMock = nil
        self.viewModel = nil
        
        Current = World()
    }

    func testFetchProfileSuccess() throws {
        let result = try JSONLoader.load(fileName: "Profile")
        setupPresenter(with: result)
        
        XCTAssertEqual(self.viewModel.emailText, "johndoe@email.com")
        XCTAssertEqual(self.viewModel.fullNameText, "John Doe")
    }
    
    func testFetchProfileFailed() throws {
        setupPresenter(with: .init(data: nil, urlResponse: nil, error: URLSessionMock.NetworkError.someError))
        
        XCTAssertNil(self.viewModel.emailText)
        XCTAssertNil(self.viewModel.fullNameText)
        XCTAssertTrue(self.viewModel.isShowingError)
    }

}
