//
//  MessageContentCard.swift
//  Dozy
//
//  Created by Andrew Daniel on 7/18/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import SwiftUI

struct MessageContentCard: View {
    
    let image: UIImage?
    let bodyText: String?
    let channel: (isPublic: Bool, text: String)
    let actionButtonTitle: String
    let actionButtonTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            image.map {
                Image(uiImage: $0)
                    .resizable()
                    .scaledToFit()
            }
            bodyText.map {
                Text($0)
                    .padding(.horizontal, 16)
                    .padding(.top, (image == nil) ? 24 : 0)
            }
            Divider()
                .foregroundColor(Color.borderGray)
            HStack {
                ChannelView(isPublic: channel.isPublic, text: channel.text)
                Spacer()
                Button(action: actionButtonTap) {
                    Text(actionButtonTitle)
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
        return MessageContentCard(
            image: UIImage(named: "FunnyPhoto"),
            bodyText: "Lorem ipsum dolor sit amet, consecte adipiscing elit.",
            channel: (isPublic: true, text: "general"),
            actionButtonTitle: "Edit",
            actionButtonTap: {}
        )
    }
}
