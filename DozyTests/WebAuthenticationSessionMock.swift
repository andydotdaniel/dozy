//
//  WebAuthenticationSessionMock.swift
//  DozyTests
//
//  Created by Andrew Daniel on 6/21/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import Foundation
import AuthenticationServices
@testable import Dozy

class WebAuthenticationSessionMock: WebAuthenticationSessionable {
    
    let requestIdentifier: String
    var callbackURLScheme: String?
    var completionHandler: ASWebAuthenticationSession.CompletionHandler?
    
    init(requestIdentifier: String) {
        self.requestIdentifier = requestIdentifier
    }
    
    func start(
        url: URL,
        callbackURLScheme: String,
        presentationContext: ASWebAuthenticationPresentationContextProviding,
        completionHandler: @escaping ASWebAuthenticationSession.CompletionHandler
    ) {
        self.callbackURLScheme = callbackURLScheme
        self.completionHandler = completionHandler
    }
    
}
