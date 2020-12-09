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
    
}

struct ProfileView: View {
    
    @ObservedObject private var viewModel: ProfileViewModel
    
    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 90) {
            if let fullNameText = viewModel.fullNameText, let emailText = viewModel.emailText {
                getProfileDetailsView(title: fullNameText, subtitle: emailText)
            } else {
                getProfileLoadingView()
            }
            
            AlternativeButton(titleText: "Logout", tapAction: {}, icon: nil, isLoading: $viewModel.buttonIsLoading)
                .frame(maxWidth: .infinity)
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 16)
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
    
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(viewModel: ProfileViewModel())
    }
}
