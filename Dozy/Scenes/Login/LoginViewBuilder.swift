//
//  LoginViewBuilder.swift
//  Dozy
//
//  Created by Andrew Daniel on 6/15/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

private class LoginViewController: UIHostingController<LoginView> {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
}

struct LoginViewBuilder: ViewControllerBuilder {
    
    private weak var navigationControllable: NavigationControllable?
    
    init(navigationControllable: NavigationControllable?) {
        self.navigationControllable = navigationControllable
    }
    
    func buildViewController() -> UIViewController {
        let viewModel = LoginViewModel()
        let authenticationSession = WebAuthenticationSession(requestIdentifier: UUID().uuidString)
        let presenter: LoginViewPresenter = LoginPresenter(
            authenticationSession: authenticationSession,
            networkService: NetworkService(),
            viewModel: viewModel,
            navigationControllable: self.navigationControllable
        )
        let view = LoginView(viewModel: viewModel, presenter: presenter)
        
        return LoginViewController(rootView: view)
    }
    
}


