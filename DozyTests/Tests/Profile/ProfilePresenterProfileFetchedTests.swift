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
    
    override func setUpWithError() throws {
        viewModel = ProfileViewModel()
        
        let urlSessionMock = URLSessionMock()
        navigationControllable = NavigationControllableMock()
        
        scheduleUserDefaultsMock = ScheduleUserDefaultsMock()
        profileUserDefaultsMock = ProfileUserDefaultsMock()
        profileUserDefaultsMock.profileSaved = Profile(name: "SOME_NAME", email: "SOME_EMAIL")
        
        presenter = ProfilePresenter(
            profileUserDefaults: profileUserDefaultsMock,
            scheduleUserDefaults: scheduleUserDefaultsMock,
            viewModel: viewModel,
            networkService: NetworkService(urlSession: urlSessionMock),
            keychain: KeychainMock(),
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

    func testOnLogoutButtonTapped() {
        self.presenter.onLogoutButtonTapped()
        XCTAssertTrue(self.viewModel.isShowingLogoutAlert)
    }
    
    func testOnLogoutConfirmed() {
        self.presenter.onLogoutConfirmed()
        
        XCTAssertTrue(self.profileUserDefaultsMock.deleteCalled)
        XCTAssertTrue(self.scheduleUserDefaultsMock.deleteCalled)
        
        XCTAssertEqual(self.navigationControllable.pushViewControllerCalledWithArgs?.animated, true)
        XCTAssertTrue(self.navigationControllable.pushViewControllerCalledWithArgs?.viewController is LoginViewController)
        
        XCTAssertEqual(self.navigationControllable.viewControllers.count, 1)
    }
    
    func testOnLogoutCancelled() {
        self.presenter.onLogoutCancelled()
        XCTAssertFalse(self.viewModel.isShowingLogoutAlert)
    }

}
