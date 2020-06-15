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
    
    private let authUrl: URL = {
        var urlComponents = URLComponents(string: "https://slack.com/oauth/v2/authorize")!
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Current.configuration.clientId),
            URLQueryItem(name: "user_scope", value: "chat:write,channels:read,groups:read"),
            URLQueryItem(name: "redirect_url", value: "dozyapp://slack/authorize/success"),
        ]
        return urlComponents.url!
    }()
    
    private var authenticationPresentationContext: ASWebAuthenticationPresentationContextProviding?
    private let networkService: NetworkRequesting
    
    init(networkService: NetworkRequesting) {
        self.networkService = networkService
    }
    
    func didTapLoginButton() {
        let session = ASWebAuthenticationSession(url: authUrl, callbackURLScheme: "dozyapp") { [weak self] callbackURL, error in
            guard error == nil, let callbackURL = callbackURL else { return }
            
            let queryItems = URLComponents(string: callbackURL.absoluteString)?.queryItems
            queryItems?.first { $0.name == "code" }.map { codeQueryItem in
                guard let requestCode = codeQueryItem.value, let self = self else { return }
                self.requestAccessToken(with: requestCode)
            }
        }
        
        let authenticationSessionViewController = AuthenticationSessionViewController()
        
        session.presentationContextProvider = authenticationSessionViewController
        self.authenticationPresentationContext = authenticationSessionViewController
        
        session.start()
    }
    
    private func requestAccessToken(with requestCode: String) {
        let url = "https://slack.com/api/oauth.v2.access"
        let parameters = [
            "code": requestCode,
            "client_id": Current.configuration.clientId,
            "client_secret": Current.configuration.clientSecret,
        ]
    
        guard let networkRequest = NetworkRequest(url: url, httpMethod: .post, parameters: parameters, contentType: .urlEncodedForm) else { return }
        networkService.peformNetworkRequest(networkRequest, completion: { (result: Result<AccessTokenResponse, NetworkService.RequestError>) -> Void  in
            switch result {
            case .success(let object):
                // TODO: Use access token from object
                break
            case .failure:
                break
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
