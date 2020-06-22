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
        GeometryReader { _ in
            NavigationView {
                ZStack(alignment: .bottom) {
                    NavigationLink(destination: OnboardingView(), tag: .onboarding, selection: self.$viewModel.navigationSelection) { EmptyView() }
                    VStack(alignment: .center, spacing: 24) {
                        VStack {
                            LoginHeaderView()
                                .zIndex(9)
                                .offset(y: 120)
                            Ellipse()
                                .foregroundColor(Color.primaryBlue)
                                .scaleEffect(3, anchor: .bottom)
                                .zIndex(1)
                                .offset(y: -40)
                        }
                        AlternativeButton(
                            titleText: "Sign in with Slack",
                            tapAction: {
                                self.presenter.didTapLoginButton()
                            },
                            icon: Image("SlackLogo"),
                            isLoading: self.$viewModel.isFetchingAccessToken
                        ).offset(y: -24)
                    }
                    Toast.createErrorToast(isShowing: self.$viewModel.isShowingError)
                }
                .navigationBarTitle("")
                .navigationBarHidden(true)
            }
        }
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
            .previewDevice(PreviewDevice(rawValue: "iPhone 11 Pro Max"))
            .previewDisplayName("iPhone 11 Pro Max")
            LoginView(
                viewModel: LoginViewModel(),
                presenter: LoginViewPreviewPresenter()
            )
            .previewDevice(PreviewDevice(rawValue: "iPhone 11"))
            .previewDisplayName("iPhone 11")
            LoginView(
                viewModel: LoginViewModel(),
                presenter: LoginViewPreviewPresenter()
            )
            .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))
            .previewDisplayName("iPhone SE (2nd generation)")
        }
    }
}
