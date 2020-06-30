//
//  LoginPresenter.swift
//  Dozy
//
//  Created by Andrew Daniel on 6/15/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import AuthenticationServices
import Foundation

protocol LoginViewPresenter: class {
    func didTapLoginButton()
}

final class LoginPresenter: LoginViewPresenter {
    
    private let authUrl: URL
    
    private var authenticationPresentationContext: ASWebAuthenticationPresentationContextProviding?
    private let authenticationSession: WebAuthenticationSessionable
    private let networkService: NetworkRequesting
    private let keychain: SecureStorable
    
    private var viewModel: LoginViewModel
    
    init(
        authenticationSession: WebAuthenticationSessionable,
        networkService: NetworkRequesting,
        viewModel: LoginViewModel,
        keychain: SecureStorable = Keychain()
    ) {
        self.authenticationSession = authenticationSession
        self.networkService = networkService
        self.viewModel = viewModel
        self.keychain = keychain
                
        var urlComponents = URLComponents(string: "https://slack.com/oauth/v2/authorize")!
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Current.configuration.clientId),
            URLQueryItem(name: "user_scope", value: "chat:write,channels:read,groups:read"),
            URLQueryItem(name: "redirect_url", value: "dozyapp://slack/authorize/success"),
            URLQueryItem(name: "state", value: self.authenticationSession.requestIdentifier)
        ]
        self.authUrl = urlComponents.url!
    }
    
    func didTapLoginButton() {
        let authenticationSessionCompletionHandler: ASWebAuthenticationSession.CompletionHandler = { [weak self] callbackURL, error in
            guard error == nil, let callbackURL = callbackURL, let self = self else { return }
            
            let queryItems = URLComponents(string: callbackURL.absoluteString)?.queryItems
            
            guard let state = queryItems?.first(where: { $0.name == "state" })?.value,
                state == self.authenticationSession.requestIdentifier else {
                    self.viewModel.isShowingError = true
                    return
            }
            
            queryItems?.first { $0.name == "code" }.map { codeQueryItem in
                guard let requestCode = codeQueryItem.value else {
                    self.viewModel.isShowingError = true
                    return
                }
                
                self.viewModel.isFetchingAccessToken = true
                self.requestAccessToken(with: requestCode)
            }
        }
        
        let authenticationSessionViewController = AuthenticationSessionViewController()
        self.authenticationPresentationContext = authenticationSessionViewController
        
        authenticationSession.start(
            url: authUrl,
            callbackURLScheme: "dozyapp",
            presentationContext: authenticationSessionViewController,
            completionHandler: authenticationSessionCompletionHandler
        )
    }
    
    private func requestAccessToken(with requestCode: String) {
        let url = "https://slack.com/api/oauth.v2.access"
        let parameters = [
            "code": requestCode,
            "client_id": Current.configuration.clientId,
            "client_secret": Current.configuration.clientSecret,
        ]
    
        guard let networkRequest = NetworkRequest(url: url, httpMethod: .post, parameters: parameters, contentType: .urlEncodedForm) else { return }
        networkService.peformNetworkRequest(networkRequest, completion: { [weak self] (result: Result<AccessTokenResponse, NetworkService.RequestError>) -> Void  in
            guard let self = self else { return }
            
            Current.dispatchQueue.async {
                switch result {
                case .success(let object):
                    guard let data = object.accessToken.data(using: .utf8) else {
                        self.viewModel.isShowingError = true
                        return
                    }
                    _ = self.keychain.save(key: "slack_access_token", data: data)
                    self.viewModel.navigationSelection = .onboarding
                case .failure:
                    self.viewModel.isFetchingAccessToken = false
                    self.viewModel.isShowingError = true
                }
            }
        })
    }
    
}

private struct AccessTokenResponse: Decodable {
    let accessToken: String
    
    enum AuthedUserCodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
    
    enum CodingKeys: String, CodingKey {
        case authedUser = "authed_user"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let authedUserContainer = try container.nestedContainer(keyedBy: AuthedUserCodingKeys.self, forKey: .authedUser)
        
        accessToken = try authedUserContainer.decode(String.self, forKey: .accessToken)
    }
}
