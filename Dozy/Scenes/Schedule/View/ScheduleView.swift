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
                .foregroundColor(Color.primaryBlue)
                .frame(height: UIScreen.main.bounds.height / 2)
                .scaleEffect(1.1)
                .scaleEffect(2, anchor: .top)
                .offset(y: 40)
            VStack(spacing: 24) {
                Image("LogoGray")
                    .frame(width: 58)
                ContentCard(viewModel: $viewModel.contentCard)
                MessageContentCard(image: nil, bodyText: "Some message here", actionButton: (titleText: "Edit", tapAction: {}), channel: (isPublic: true, text: "general"))
                Spacer()
            }
            .padding(.top, 12)
            .padding(.horizontal, 24)
            Switch(position: viewModel.state == .active ? .on : .off, delegate: self.presenter)
        }
    }
}

struct ScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        let channel = Channel(id: "SOME_ID", isPublic: true, text: "general")
        let message = Message(image: nil, bodyText: "Some body text", channel: channel)
        let schedule = Schedule(message: message, awakeConfirmationTime: Date())
        let viewModel = ScheduleViewModel(state: .active, schedule: schedule)
        let presenter = SchedulePresenter(viewModel: viewModel)
        return ScheduleView(viewModel: viewModel, presenter: presenter)
    }
}
