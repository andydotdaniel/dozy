//
//  ChannelItemView.swift
//  Dozy
//
//  Created by Andrew Daniel on 7/5/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import SwiftUI

struct ChannelItem: Identifiable {
    
    var id: UUID
    let isPublic: Bool
    let text: String
    
    init(isPublic: Bool, text: String) {
        self.id = UUID()
        self.isPublic = isPublic
        self.text = text
    }
    
}

struct ChannelItemView: View {
    
    var content: ChannelItem
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Image(content.isPublic ? "IconHashtag" : "IconLock")
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16)
            Text(content.text)
                .font(.system(size: 18))
                .bold()
        }
    }
    
}

struct ChannelItemView_Previews: PreviewProvider {
    static var previews: some View {
        let content = ChannelItem(isPublic: true, text: "general")
        return ChannelItemView(content: content)
    }
}
