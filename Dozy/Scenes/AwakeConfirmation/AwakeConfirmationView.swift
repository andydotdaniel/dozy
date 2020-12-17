//
//  AwakeConfirmationView.swift
//  Dozy
//
//  Created by Andrew Daniel on 8/23/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import SwiftUI

class AwakeConfirmationViewModel: ObservableObject {
    
    @Published var countdownActive: Bool
    @Published var secondsLeft: Int
    
    init(countdownActive: Bool, secondsLeft: Int) {
        self.countdownActive = countdownActive
        self.secondsLeft = secondsLeft
    }
    
}

struct AwakeConfirmationView: View {
    
    @ObservedObject private var viewModel: AwakeConfirmationViewModel
    private let presenter: AwakeConfirmationViewPresenter
    
    init(viewModel: AwakeConfirmationViewModel, presenter: AwakeConfirmationViewPresenter) {
        self.viewModel = viewModel
        self.presenter = presenter
    }
    
    var body: some View {
        VStack() {
            Spacer()
            VStack(alignment: .center, spacing: -16) {
                Text("\(self.viewModel.secondsLeft)")
                    .bold()
                    .font(.system(size: 180))
                Text("Confirm you're awake.")
                    .bold()
            }.foregroundColor(self.viewModel.countdownActive ? Color.primaryBlue : Color.borderGray)
            Spacer()
            Slider(titleText: "Slide for awake confirmation", delegate: presenter)
                .offset(y: -24)
        }
        .padding(.bottom, 16)
        .padding(.horizontal, 16)
    }
    
}

struct AwakeConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        let channel = Channel(id: "SOME_CHANNEL_ID", isPublic: false, text: "SOME_TEXT")
        let message = Message(image: nil, bodyText: "SOME_TEXT", channel: channel)
        let schedule = Schedule(message: message, awakeConfirmationTime: Date().addingTimeInterval(30), scheduledMessageId: nil)
        
        let viewModel = AwakeConfirmationViewModel(countdownActive: true, secondsLeft: 30)
        let presenter = AwakeConfirmationPresenter(viewModel: viewModel, networkService: NetworkService(), keychain: Keychain(), userDefaults: ScheduleUserDefaults(), savedSchedule: schedule, navigationControllable: nil)
        
        return Group {
            AwakeConfirmationView(viewModel: viewModel, presenter: presenter)
                .previewDevice(PreviewDevice(rawValue: "iPhone 11"))
                .previewDisplayName("iPhone 11")
            AwakeConfirmationView(viewModel: viewModel, presenter: presenter)
                .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))
                .previewDisplayName("iPhone SE (2nd generation)")
        }
        
    }
}
