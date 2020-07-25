//
//  ContentCard.swift
//  Dozy
//
//  Created by Andrew Daniel on 7/18/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import SwiftUI

struct ContentCard: View {
    
    class ViewModel: ObservableObject {
        
        enum State {
            case disabled
            case enabled
        }
        
        var state: State
        let titleText: String
        let subtitleText: String
        var bodyText: Text
        let buttonText: String
        
        init(state: State, titleText: String, subtitleText: String, bodyText: Text, buttonText: String) {
            self.state = state
            self.titleText = titleText
            self.subtitleText = subtitleText
            self.bodyText = bodyText
            self.buttonText = buttonText
        }
        
    }
    
    @Binding var viewModel: ViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(alignment: .center) {
                Text(viewModel.titleText)
                    .fontWeight(.bold)
                    .font(.system(size: 21))
                    .foregroundColor(Color.white)
                Spacer()
                Text(viewModel.subtitleText)
                    .foregroundColor(Color.white)
            }
            viewModel.bodyText
            SecondaryButton(
                titleText: viewModel.buttonText, tapAction: {},
                color: viewModel.state == .enabled ? Color.darkBlue : Color.darkRed
            )
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 28)
        .background(viewModel.state == .enabled ? Color.primaryBlue: Color.alertRed)
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
        
        let viewModel = ContentCard.ViewModel(
            state: .enabled,
            titleText: "8:10am",
            subtitleText: "May 17",
            bodyText: bodyText,
            buttonText: "Change awake confirmation time"
        )
        
        return ContentCard(viewModel: .constant(viewModel))
    }
}
