//
//  ScheduleView.swift
//  Dozy
//
//  Created by Andrew Daniel on 7/19/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import SwiftUI

struct ScheduleView: View {
    
    @State var presenter: ScheduleViewPresenter
    
    private var contentCardBodyText: Text {
        let bodyText: Text = Text("Open the app in ")
            .foregroundColor(Color.white) +
        Text("07:18:36")
            .foregroundColor(Color.white)
            .bold() +
        Text(" or your sleepyhead message gets sent.")
            .foregroundColor(Color.white)
        
        return bodyText
    }
    
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
                ContentCard(state: self.$presenter.viewModel.contentCardState, titleText: "8:50am", subtitleText: "May 17", bodyText: contentCardBodyText, buttonText: "Change awake confirmation time")
                MessageContentCard(image: nil, bodyText: "Some message here", actionButton: (titleText: "Edit", tapAction: {}), channel: (isPublic: true, text: "general"))
                Spacer()
            }
            .padding(.top, 12)
            .padding(.horizontal, 24)
            Switch(state: self.$presenter.viewModel.switchState)
        }
    }
}

struct ScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = ScheduleViewModel(state: .active)
        let presenter = SchedulePresenter(viewModel: viewModel)
        return ScheduleView(presenter: presenter)
    }
}
