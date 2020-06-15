//
//  AuthenticationSessionView.swift
//  Dozy
//
//  Created by Andrew Daniel on 6/15/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import AuthenticationServices
import SwiftUI
import UIKit

final class AuthenticationSessionViewController: UIViewController, ASWebAuthenticationPresentationContextProviding {
    
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return Current.window!
    }
    
}
