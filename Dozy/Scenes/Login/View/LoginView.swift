//
//  LoginView.swift
//  Dozy
//
//  Created by Andrew Daniel on 6/14/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import Foundation
import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: LoginViewModel
    var presenter: LoginViewPresenter
    
    var body: some View {
        VStack(alignment: .center, spacing: 24) {
            VStack {
                LoginHeaderView()
                    .zIndex(9)
                Ellipse()
                    .frame(height: 90)
                    .offset(y: -10)
                    .foregroundColor(Color.primaryBlue)
                    .scaleEffect(1.3, anchor: .bottom)
                    .zIndex(1)
            }
            AlternativeButton(
                titleText: "Sign in with Slack",
                tapAction: {
                    self.presenter.didTapLoginButton()
                },
                icon: Image("SlackLogo"),
                isLoading: $viewModel.isFetchingAccessToken
            )
        }.offset(y: -48)
    }
}

struct LoginView_Previews: PreviewProvider {
    
    class LoginViewPreviewPresenter: LoginViewPresenter {
        func didTapLoginButton() {}
    }
    
    static var previews: some View {
        Group {
            LoginView(
                viewModel: LoginViewModel(),
                presenter: LoginViewPreviewPresenter()
            )
        }
    }
}
