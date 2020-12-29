//
//  ProfilePresenterProfileFetchedTests.swift
//  DozyTests
//
//  Created by Andrew Daniel on 12/15/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

@testable import Dozy
import XCTest

class ProfilePresenterProfileFetchedTests: XCTestCase {

    private var presenter: ProfilePresenter!
    private var viewModel: ProfileViewModel!
    
    private var navigationControllable: NavigationControllableMock!
    
    private var profileUserDefaultsMock: ProfileUserDefaultsMock!
    private var scheduleUserDefaultsMock: ScheduleUserDefaultsMock!
    private var keychainMock: KeychainMock!
    
    override func setUpWithError() throws {
        viewModel = ProfileViewModel()
        
        let urlSessionMock = URLSessionMock()
        navigationControllable = NavigationControllableMock()
        
        scheduleUserDefaultsMock = ScheduleUserDefaultsMock()
        let channel = Channel(id: "SOME_CHANNEL_ID", isPublic: false, text: "SOME_TEXT")
        let message = Message(image: nil, imageUrl: nil, bodyText: "SOME_TEXT", channel: channel)
        scheduleUserDefaultsMock.scheduleSaved = Schedule(message: message, awakeConfirmationTime: Current.now().addingTimeInterval(180), scheduledMessageId: nil)
        
        profileUserDefaultsMock = ProfileUserDefaultsMock()
        profileUserDefaultsMock.profileSaved = Profile(name: "SOME_NAME", email: "SOME_EMAIL")
        
        keychainMock = KeychainMock()
        
        presenter = ProfilePresenter(
            profileUserDefaults: profileUserDefaultsMock,
            scheduleUserDefaults: scheduleUserDefaultsMock,
            viewModel: viewModel,
            networkService: NetworkService(urlSession: urlSessionMock),
            keychain: keychainMock,
            navigationControllable: navigationControllable
        )
    }

    override func tearDownWithError() throws {
        self.presenter = nil
        self.navigationControllable = nil
        self.profileUserDefaultsMock = nil
        self.scheduleUserDefaultsMock = nil
        self.viewModel = nil
    }
    
    func testProfileShown() {
        XCTAssertEqual(viewModel.fullNameText, profileUserDefaultsMock.profileSaved!.name)
        XCTAssertEqual(viewModel.emailText, profileUserDefaultsMock.profileSaved!.email)
    }

    func testOnLogoutButtonTappedWithActiveSchedule() {
        scheduleUserDefaultsMock.scheduleSaved?.scheduledMessageId = "SOME_SCHEDULED_MESSAGE_ID"
        self.presenter.onLogoutButtonTapped()
        
        XCTAssertFalse(self.viewModel.shouldShowLogoutAlert)
        XCTAssertTrue(self.viewModel.isShowingAlert)
    }
    
    func testOnLogoutButtonTappedWithoutActiveSchedule() {
        self.presenter.onLogoutButtonTapped()
        
        XCTAssertTrue(self.viewModel.shouldShowLogoutAlert)
        XCTAssertTrue(self.viewModel.isShowingAlert)
    }
    
    func testOnLogoutConfirmed() {
        self.presenter.onLogoutConfirmed()
        
        XCTAssertTrue(self.profileUserDefaultsMock.deleteCalled)
        XCTAssertTrue(self.scheduleUserDefaultsMock.deleteCalled)
        XCTAssertEqual(self.keychainMock.deleteKey, Keychain.Keys.slackAccessToken)
        
        XCTAssertEqual(self.navigationControllable.pushViewControllerCalledWithArgs?.animated, true)
        XCTAssertTrue(self.navigationControllable.pushViewControllerCalledWithArgs?.viewController is LoginViewController)
        
        XCTAssertEqual(self.navigationControllable.viewControllers.count, 1)
    }
    
    func testOnLogoutCancelled() {
        self.presenter.onDismissAlertTapped()
        XCTAssertFalse(self.viewModel.isShowingAlert)
    }

}
