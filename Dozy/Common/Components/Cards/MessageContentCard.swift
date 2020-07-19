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
    let actionButton: (titleText: String, tapAction: () -> Void)
    let channel: (isPublic: Bool, text: String)
    
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
                Button(action: actionButton.tapAction) {
                    Text(actionButton.titleText)
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
        MessageContentCard(
            image: UIImage(named: "FunnyPhoto"),
            bodyText: "Lorem ipsum dolor sit amet, consecte adipiscing elit.",
            actionButton: (titleText: "Edit", tapAction: {}),
            channel: (isPublic: true, text: "general")
        )
    }
}
