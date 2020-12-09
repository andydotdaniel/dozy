//
//  ScheduleView.swift
//  Dozy
//
//  Created by Andrew Daniel on 7/19/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import SwiftUI

struct ScheduleView: View {
    
    @ObservedObject var viewModel: ScheduleViewModel
    var presenter: ScheduleViewPresenter
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Ellipse()
                .foregroundColor(viewModel.state == .active ? Color.primaryBlue : Color.alertRed)
                .frame(height: UIScreen.main.bounds.height / 2)
                .scaleEffect(1.1)
                .scaleEffect(2, anchor: .top)
                .offset(y: 40)
            VStack {
                Image("LogoGray")
                    .frame(width: 58)
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        ContentCard(viewModel: $viewModel.awakeConfirmationCard, buttonAction: {
                            withAnimation {
                                self.viewModel.awakeConfirmationCard.isShowingTimePicker = true
                            }
                        }, timePickerActions: (cancelButton: self.presenter.onTimePickerCancelButtonTapped, doneButton: self.presenter.onTimePickerDoneButtonTapped))
                        MessageContentCard(
                            image: viewModel.messageCard.image,
                            bodyText: viewModel.messageCard.bodyText,
                            channel: (isPublic: viewModel.messageCard.channel.isPublic, text: viewModel.messageCard.channel.text),
                            actionButtonTitle: viewModel.messageCard.actionButtonTitle,
                            actionButtonTap: { self.presenter.onMessageActionButtonTapped() }
                        )
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 48)
                }
            }
            .padding(.top, 12)
            Switch(switchState: $viewModel.switchPosition, delegate: self.presenter)
                .offset(y: UIDevice.current.screenType == .small ? -24 : 0)
        }.sheet(isPresented: self.$viewModel.isShowingMessageForm, content: {
            self.presenter.navigateToMessageForm()
        })
    }
}

struct ScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        let channel = Channel(id: "SOME_ID", isPublic: true, text: "general")
        let message = Message(image: nil, bodyText: "Some body text", channel: channel)
        let schedule = Schedule(message: message, awakeConfirmationTime: Date(), scheduledMessageId: nil)
        let viewModel = ScheduleViewModel(schedule: schedule)
        let presenter = SchedulePresenter(schedule: schedule, viewModel: viewModel, userDefaults: UserDefaults.standard, networkService: NetworkService(), keychain: Keychain())
        return ScheduleView(viewModel: viewModel, presenter: presenter)
            .previewDevice("iPhone 11")
    }
}
