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
    
    private let headerHeight: CGFloat = 58
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Ellipse()
                .foregroundColor(viewModel.state == .active ? Color.primaryBlue : Color.alertRed)
                .frame(height: UIScreen.main.bounds.height / 2)
                .scaleEffect(1.1)
                .scaleEffect(2, anchor: .top)
                .offset(y: 40)
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 12) {
                    HeaderMain(height: headerHeight, delegate: presenter)
                    VStack(spacing: 24) {
                        getContentCard()
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
                    .padding(.bottom, 48)
                }
                .padding(.top, 4)
            }
            Switch(switchState: $viewModel.switchPosition, delegate: self.presenter)
                .offset(y: UIDevice.current.screenType == .small ? -24 : 0)
            viewModel.errorToastText.map { text in
                Toast.createErrorToast(text: text, isShowing: $viewModel.errorToastIsShowing)
                    .transition(.move(edge: .bottom))
            }
        }.sheet(isPresented: self.$viewModel.isShowingMessageForm, content: {
            self.presenter.navigateToMessageForm()
        })
    }
    
    private func getContentCard() -> AnyView {
        let contentCard = ContentCard(viewModel: $viewModel.awakeConfirmationCard, buttonAction: {
            self.presenter.onChangeAwakeConfirmationTimeTapped()
        }, timePickerActions: (cancelButton: self.presenter.onTimePickerCancelButtonTapped, doneButton: self.presenter.onTimePickerDoneButtonTapped)
        )
        if viewModel.isShowingOverlayCard, let overlayCardText = viewModel.overlayCardText {
            return AnyView(contentCard.overlay(
                OverlayCard(
                    text: overlayCardText,
                    delegate: self.presenter
                )
                .background(Color.white)
                .cornerRadius(18)
            ))
        } else {
            return AnyView(contentCard)
        }
    }
}

struct ScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        let channel = Channel(id: "SOME_ID", isPublic: true, text: "general")
        let message = Message(imageName: nil, imageUrl: nil, bodyText: "Some body text", channel: channel)
        let schedule = Schedule(message: message, awakeConfirmationTime: Date(), scheduledMessageId: nil)
        let viewModel = ScheduleViewModel(schedule: schedule)
        let presenter = SchedulePresenter(schedule: schedule, isPostMessageSent: .notSent, viewModel: viewModel, userDefaults: ScheduleUserDefaults(), networkService: NetworkService(), keychain: Keychain(), navigationControllable: nil, awakeConfirmationTimer: ActionTimer(), userNotificationCenter: UNUserNotificationCenter.current())
        return ScheduleView(viewModel: viewModel, presenter: presenter)
            .previewDevice("iPhone 8")
    }
}
