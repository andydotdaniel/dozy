//
//  OverlayCard.swift
//  Dozy
//
//  Created by Andrew Daniel on 12/18/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import SwiftUI

struct OverlayCard: View {
    
    let text: String
    let dismissAction: () -> Void
    
    var body: some View {
        VStack(alignment: .center, spacing: 36) {
            Text(text)
                .foregroundColor(Color.black)
                .fontWeight(.bold)
            Text("Dismiss")
                .bold()
                .foregroundColor(Color.primaryBlue)
                .onTapGesture {
                    dismissAction()
                }
        }
        .padding(24)
        .background(Color.white)
        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
    }
}

struct OverlayCard_Previews: PreviewProvider {
    static var previews: some View {
        OverlayCard(text: "Your message was sent you sleepyhead", dismissAction: {})
    }
}
