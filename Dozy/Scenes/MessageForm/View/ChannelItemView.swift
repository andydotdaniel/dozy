//
//  ChannelItemView.swift
//  Dozy
//
//  Created by Andrew Daniel on 7/5/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import SwiftUI

struct ChannelItemView: View {
    
    var isPublic: Bool
    var text: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Image(isPublic ? "IconHashtag" : "IconLock")
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16)
            Text(text)
                .font(.system(size: 18))
                .bold()
        }
    }
    
}

struct ChannelItemView_Previews: PreviewProvider {
    static var previews: some View {
        let content = Channel(id: "C061EG9T2", isPublic: true, text: "general")
        return ChannelItemView(isPublic: content.isPublic, text: content.text)
    }
}
