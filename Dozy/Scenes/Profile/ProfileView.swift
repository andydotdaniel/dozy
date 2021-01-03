//
//  ProfileView.swift
//  Dozy
//
//  Created by Andrew Daniel on 12/9/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import SwiftUI

class ProfileViewModel: ObservableObject {
    
    @Published var fullNameText: String?
    @Published var emailText: String?
    
    @Published var buttonIsLoading: Bool = false
    @Published var isShowingError: Bool = false
    
    @Published var isShowingAlert: Bool = false
    var shouldShowLogoutAlert: Bool = false
    
}

struct ProfileView: View {
    
    @ObservedObject private var viewModel: ProfileViewModel
    private var presenter: ProfileViewPresenter
    
    init(viewModel: ProfileViewModel, presenter: ProfileViewPresenter) {
        self.viewModel = viewModel
        self.presenter = presenter
    }
    
    var body: some View {
        VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 90) {
            if let fullNameText = viewModel.fullNameText, let emailText = viewModel.emailText {
                getProfileDetailsView(title: fullNameText, subtitle: emailText)
            } else if viewModel.isShowingError {
                getErrorView()
            } else {
                getProfileLoadingView()
            }
            
            AlternativeButton(
                titleText: "Logout",
                tapAction: { self.presenter.onLogoutButtonTapped() },
                isLoading: $viewModel.buttonIsLoading
            )
            .frame(maxWidth: .infinity)
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 16)
        .alert(isPresented: $viewModel.isShowingAlert, content: { getAlert() })
    }
    
    private func getAlert() -> Alert {
        if viewModel.shouldShowLogoutAlert {
            let confirmButton: Alert.Button = .default(Text("Yes"), action: {
                self.presenter.onLogoutConfirmed()
            })
            
            let cancelButton: Alert.Button = .default(Text("No"), action: {
                self.presenter.onDismissAlertTapped()
            })
            
            return Alert(
                title: Text("Confirm Logout"),
                message: Text("Are you sure you want to logout?"),
                primaryButton: cancelButton,
                secondaryButton: confirmButton
            )
        } else {
            let okButton: Alert.Button = .default(Text("Ok"), action: {
                self.presenter.onDismissAlertTapped()
            })
            
            return Alert(
                title: Text("Cannot Logout With Active Timer"),
                message: Text("You have an active awake confirmation timer running. Please turn it off before logging out."),
                dismissButton: okButton
            )
        }
    }
    
    private func getProfileDetailsView(title: String, subtitle: String) -> AnyView {
        AnyView(
            VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 8) {
            Text("You're signed in as")
                .font(.body)
                .foregroundColor(Color.placeholderGray)
            Text(title)
                .bold()
                .font(.largeTitle)
            Text(subtitle)
                .font(.title2)
            }
        )
    }
    
    private func getProfileLoadingView() -> AnyView {
        AnyView(
            HStack(alignment: .center, spacing: 12) {
                Spinner(strokeColor: Color.primaryBlue)
                Text("Fetching profile information...")
                    .font(.body)
            }
        )
    }
    
    private func getErrorView() -> AnyView {
        AnyView(
            VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 8) {
            Text("Oops.")
                .foregroundColor(Color.alertRed)
                .bold()
                .font(.largeTitle)
            Text("We failed to fetch your profile information.")
                .font(.title2)
            }
        )
    }
    
}

struct ProfileView_Previews: PreviewProvider {
    
    private class PreviewProfileViewPresenter: ProfileViewPresenter {
        func onLogoutButtonTapped() {}
        func onDismissAlertTapped() {}
        func onLogoutConfirmed() {}
    }
    
    static var previews: some View {
        ProfileView(viewModel: ProfileViewModel(), presenter: PreviewProfileViewPresenter())
    }
}
