//
//  OverlayCard.swift
//  Dozy
//
//  Created by Andrew Daniel on 12/18/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import SwiftUI

protocol OverlayCardDelegate: class {
    func onOverlayCardDismissButtonTapped()
}

struct OverlayCard: View {
    
    let text: String
    
    weak var delegate: OverlayCardDelegate?
    
    var body: some View {
        VStack(alignment: .center, spacing: 36) {
            Text(text)
                .foregroundColor(Color.black)
                .fontWeight(.bold)
            if let delegate = self.delegate {
                Button(action: delegate.onOverlayCardDismissButtonTapped) {
                    Text("Dismiss")
                    .font(.system(size: 18))
                    .bold()
                    .foregroundColor(Color.primaryBlue)
                }
            }
        }
        .padding(24)
        .background(Color.white)
        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
    }
}

struct OverlayCard_Previews: PreviewProvider {
    static var previews: some View {
        OverlayCard(text: "Your message was sent you sleepyhead")
    }
}
