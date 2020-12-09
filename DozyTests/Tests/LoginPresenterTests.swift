//
//  LoginPresenterTests.swift
//  DozyTests
//
//  Created by Andrew Daniel on 6/14/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import XCTest
@testable import Dozy

class LoginPresenterTests: XCTestCase {

    var presenter: LoginPresenter!
    var viewModel: LoginViewModel!
    var urlSessionMock: URLSessionMock!
    var navigationControllableMock: NavigationControllableMock!
    var authenticationSessionMock: WebAuthenticationSessionMock!
    var authRequestIdentifier: String!
    var keychainMock: KeychainMock!
    
    override func setUpWithError() throws {
        Current = .mock
        
        authRequestIdentifier = UUID().uuidString
        authenticationSessionMock = WebAuthenticationSessionMock(requestIdentifier: authRequestIdentifier)
        urlSessionMock = URLSessionMock()
        viewModel = LoginViewModel()
        let networkService = NetworkService(urlSession: urlSessionMock)
        keychainMock = KeychainMock()
        
        navigationControllableMock = NavigationControllableMock()
        
        presenter = LoginPresenter(
            authenticationSession: authenticationSessionMock,
            networkService: networkService,
            viewModel: viewModel,
            keychain: keychainMock,
            navigationControllable: navigationControllableMock
        )
    }

    override func tearDownWithError() throws {
        presenter = nil
        viewModel = nil
        urlSessionMock = nil
        
        Current = World()
    }

    func testDidTapLoginButton() throws {
        presenter.didTapLoginButton()
        
        XCTAssertEqual(authenticationSessionMock.callbackURLScheme, "dozyapp")
        XCTAssertNotNil(authenticationSessionMock.completionHandler)
        
        let jsonDictionary: [String: Any] = [
            "authed_user": [
                "access_token": "SOME_SLACK_TOKEN"
            ]
        ]
        let data = try JSONSerialization.data(withJSONObject: jsonDictionary, options: .prettyPrinted)
        urlSessionMock.result = URLSessionMockResult(data: data, urlResponse: nil, error: nil)
        
        var callbackURLComponents: URLComponents = URLComponents(string: "http://slack.com/some-callback-url")!
        callbackURLComponents.queryItems = [
            URLQueryItem(name: "state", value: authRequestIdentifier),
            URLQueryItem(name: "code", value: "SOME_AUTHORIZATION_CODE")
        ]
        authenticationSessionMock.completionHandler!(callbackURLComponents.url, nil)
        
        XCTAssertTrue(viewModel.isFetchingAccessToken)
        XCTAssertFalse(viewModel.isShowingError)
        XCTAssertEqual(keychainMock.saveKey, "slack_access_token")
        XCTAssertEqual(keychainMock.saveData, "SOME_SLACK_TOKEN".data(using: .utf8))
    }

}
