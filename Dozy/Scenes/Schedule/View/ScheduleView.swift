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
            VStack(spacing: 24) {
                Image("LogoGray")
                    .frame(width: 58)
                ContentCard(viewModel: $viewModel.awakeConfirmationCard)
                MessageContentCard(
                    image: viewModel.messageCard.image,
                    bodyText: viewModel.messageCard.bodyText,
                    channel: (isPublic: viewModel.messageCard.channel.isPublic, text: viewModel.messageCard.channel.text),
                    actionButtonTitle: viewModel.messageCard.actionButtonTitle,
                    actionButtonTap: { self.presenter.onMessageActionButtonTapped() }
                )
                Spacer()
            }
            .padding(.top, 12)
            .padding(.horizontal, 24)
            Switch(position: viewModel.state == .active ? .on : .off, delegate: self.presenter)
        }.sheet(isPresented: self.$viewModel.isShowingMessageForm, content: {
            MessageFormViewBuilder(hasMessage: true, delegate: self.presenter).build()
        })
    }
}

struct ScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        let channel = Channel(id: "SOME_ID", isPublic: true, text: "general")
        let message = Message(image: nil, bodyText: "Some body text", channel: channel)
        let schedule = Schedule(message: message, awakeConfirmationTime: Date(), isActive: true)
        let viewModel = ScheduleViewModel(schedule: schedule)
        let presenter = SchedulePresenter(schedule: schedule, viewModel: viewModel)
        return ScheduleView(viewModel: viewModel, presenter: presenter)
    }
}
