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
        let presenter: LoginViewPresenter = LoginPresenter(networkService: NetworkService())
        var view = LoginView()
        view.presenter = presenter
        
        return view
    }
    
}
