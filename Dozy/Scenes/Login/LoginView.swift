//
//  LoginView.swift
//  Dozy
//
//  Created by Andrew Daniel on 6/14/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import SwiftUI

struct LoginView: View {
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
                tapAction: {},
                icon: Image("SlackLogo")
            )
        }.offset(y: -48) 
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LoginView()
                .previewDevice(PreviewDevice(rawValue: "iPhone 11"))
                .previewDisplayName("iPhone 11")
            LoginView()
                .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))
                .previewDisplayName("iPhone SE (2nd generation)")
            LoginView()
                .previewDevice(PreviewDevice(rawValue: "iPhone 11 Pro Max"))
                .previewDisplayName("iPhone 11 Pro Max")
        }
    }
}
