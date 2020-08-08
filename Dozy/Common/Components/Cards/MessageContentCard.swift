//
//  MessageContentCard.swift
//  Dozy
//
//  Created by Andrew Daniel on 7/18/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import SwiftUI

struct MessageContentCard: View {
    
    struct ViewModel {
        let image: UIImage?
        let bodyText: String?
        let actionButton: (titleText: String, tapAction: () -> Void)
        let channel: (isPublic: Bool, text: String)
    }
    
    @Binding var viewModel: ViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            viewModel.image.map {
                Image(uiImage: $0)
                    .resizable()
                    .scaledToFit()
            }
            viewModel.bodyText.map {
                Text($0)
                    .padding(.horizontal, 16)
                    .padding(.top, (viewModel.image == nil) ? 24 : 0)
            }
            Divider()
                .foregroundColor(Color.borderGray)
            HStack {
                ChannelView(isPublic: viewModel.channel.isPublic, text: viewModel.channel.text)
                Spacer()
                Button(action: viewModel.actionButton.tapAction) {
                    Text(viewModel.actionButton.titleText)
                    .font(.system(size: 18))
                    .bold()
                    .foregroundColor(Color.primaryBlue)
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.bottom, 24)
        .background(Color.white)
        .cornerRadius(18)
        .shadow(radius: 5)
    }
}

struct MessageContentCard_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = MessageContentCard.ViewModel(
            image: UIImage(named: "FunnyPhoto"),
            bodyText: "Lorem ipsum dolor sit amet, consecte adipiscing elit.",
            actionButton: (titleText: "Edit", tapAction: {}),
            channel: (isPublic: true, text: "general")
        )
        return MessageContentCard(viewModel: .constant(viewModel))
    }
}
