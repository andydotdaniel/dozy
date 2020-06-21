//
//  WebAuthenticationSession.swift
//  Dozy
//
//  Created by Andrew Daniel on 6/21/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import AuthenticationServices

protocol WebAuthenticationSessionable {
    var requestIdentifier: String { get }
    func start(
        url: URL,
        callbackURLScheme: String,
        presentationContext: ASWebAuthenticationPresentationContextProviding,
        completionHandler: @escaping ASWebAuthenticationSession.CompletionHandler
    )
}

class WebAuthenticationSession: WebAuthenticationSessionable {
    
    let requestIdentifier: String
    
    init(requestIdentifier: String) {
        self.requestIdentifier = requestIdentifier
    }
    
    func start(
        url: URL,
        callbackURLScheme: String,
        presentationContext: ASWebAuthenticationPresentationContextProviding,
        completionHandler: @escaping ASWebAuthenticationSession.CompletionHandler
    ) {
        let authenticationSession = ASWebAuthenticationSession(url: url, callbackURLScheme: callbackURLScheme, completionHandler: completionHandler)
        authenticationSession.presentationContextProvider = presentationContext
        authenticationSession.start()
    }
    
}
