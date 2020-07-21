//
//  ContentCard.swift
//  Dozy
//
//  Created by Andrew Daniel on 7/18/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import SwiftUI

struct ContentCard: View {
    
    enum State {
        case disabled
        case enabled
    }
    
    @Binding var state: State
    
    let titleText: String
    let subtitleText: String
    let bodyText: Text
    let buttonText: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(alignment: .center) {
                Text(titleText)
                    .fontWeight(.bold)
                    .font(.system(size: 21))
                    .foregroundColor(Color.white)
                Spacer()
                Text(subtitleText)
                    .foregroundColor(Color.white)
            }
            bodyText
            SecondaryButton(titleText: buttonText, tapAction: {}, color: Color.darkBlue)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 28)
        .background(state == .enabled ? Color.primaryBlue: Color.red)
        .cornerRadius(18)
    }
}

struct ContentCard_Previews: PreviewProvider {
    static var previews: some View {
        let bodyText: Text = Text("Open the app in ")
            .foregroundColor(Color.white) +
        Text("07:18:36")
            .foregroundColor(Color.white)
            .bold() +
        Text(" or your sleepyhead message gets sent.")
            .foregroundColor(Color.white)
        
        return ContentCard(
            state: .constant(.enabled),
            titleText: "8:10am",
            subtitleText: "May 17",
            bodyText: bodyText,
            buttonText: "Change awake confirmation time"
        )
    }
}
