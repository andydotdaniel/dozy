//
//  LoginViewBuilder.swift
//  Dozy
//
//  Created by Andrew Daniel on 6/15/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import Foundation

struct LoginViewBuilder: ViewBuilder {
    
    func build() -> LoginView {
        let viewModel = LoginViewModel()
        let authenticationSession = WebAuthenticationSession(requestIdentifier: UUID().uuidString)
        let presenter: LoginViewPresenter = LoginPresenter(
            authenticationSession: authenticationSession,
            networkService: NetworkService(),
            viewModel: viewModel
        )
        let view = LoginView(viewModel: viewModel, presenter: presenter)
        
        return view
    }
    
}
