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
        var urlComponents = URLComponents(string: "https://slack.com/oauth/authorize")!
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Current.configuration.clientId),
            URLQueryItem(name: "scope", value: "chat:write:user,channels:read,groups:read"),
            URLQueryItem(name: "redirect_url", value: "dozyapp://slack/authorize/success"),
        ]
        return urlComponents.url!
    }()
    
    private let session: ASWebAuthenticationSession
    
    private var authenticationPresentationContext: ASWebAuthenticationPresentationContextProviding?
    
    init() {
        session = ASWebAuthenticationSession(url: authUrl, callbackURLScheme: "dozyapp") { callbackURL, error in
            guard error == nil, let callbackURL = callbackURL else { return }
            
            let queryItems = URLComponents(string: callbackURL.absoluteString)?.queryItems
            let requestCode = queryItems?.first { $0.name == "code" }
        }
    }
    
    func didTapLoginButton() {
        let authenticationSessionViewController = AuthenticationSessionViewController()
        
        session.presentationContextProvider = authenticationSessionViewController
        self.authenticationPresentationContext = authenticationSessionViewController
        
        session.start()
    }
    
}
