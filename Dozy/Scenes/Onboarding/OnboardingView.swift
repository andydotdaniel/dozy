
//
//  OnboardingView.swift
//  Dozy
//
//  Created by Andrew Daniel on 6/22/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import Foundation
import SwiftUI

struct OnboardingView: View {
    
    @ObservedObject var viewModel: OnboardingViewModel
    var presenter: OnboardingViewPresenter
    
    init(viewModel: OnboardingViewModel, presenter: OnboardingViewPresenter) {
        self.viewModel = viewModel
        self.presenter = presenter
    }
    
    var body: some View {
        NavigationView {
            VStack {
                viewModel.messageCreatedNavigationDestination.map {
                    NavigationLink(destination: $0, isActive: self.$viewModel.shouldNavigateToSchedule) { EmptyView() }
                }
                Image("LogoGray")
                    .frame(width: 58)
                Spacer()
                VStack(alignment: .center, spacing: 40) {
                    Image("IllustrationMessage")
                        .resizable()
                        .scaledToFit()
                        .frame(width: UIDevice.current.screenType == .large ? 280 : 200)
                    VStack(alignment: .center, spacing: 24) {
                        Text("A message that keeps you awake.")
                            .bold()
                            .font(.largeTitle)
                        Text("Prevent yourself from going back to sleep with a message you’d rather not have sent to your Slack workspace. It can be an embarrassing photo or a mention to your boss—whatever it is, make sure it gets you out of bed.")
                            .font(.body)
                    }
                    .padding(.horizontal, 16)
                    .multilineTextAlignment(.center)
                    PrimaryButton(titleText: "Create message", tapAction: {
                        self.viewModel.isShowingMessageForm = true
                    }).sheet(isPresented: self.$viewModel.isShowingMessageForm, content: {
                        MessageFormViewBuilder(message: nil, delegate: self.presenter).build()
                    })
                }
                Spacer()
            }
            .padding(.top, 24)
            .navigationBarTitle("")
            .navigationBarHidden(true)
        }
    }
    
}

struct OnboardingView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            OnboardingViewBuilder().build()
            .previewDevice(PreviewDevice(rawValue: "iPhone 11 Pro Max"))
            .previewDisplayName("iPhone 11 Pro Max")
            OnboardingViewBuilder().build()
            .previewDevice(PreviewDevice(rawValue: "iPhone 11"))
            .previewDisplayName("iPhone 11")
            OnboardingViewBuilder().build()
            .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))
            .previewDisplayName("iPhone SE (2nd generation)")
        }
    }
}

