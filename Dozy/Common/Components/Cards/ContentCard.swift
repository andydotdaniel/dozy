//
//  ContentCard.swift
//  Dozy
//
//  Created by Andrew Daniel on 7/18/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import SwiftUI

struct ContentCard: View {
    
    struct ViewModel {
        
        enum State {
            case disabled
            case enabled
        }
        
        var state: State
        var titleText: String
        var subtitleText: String
        
        var preMutableText: String
        var mutableText: String
        var postMutableText: String
        
        let buttonText: String
        
        init(
            state: State,
            titleText: String,
            subtitleText: String,
            preMutableText: String,
            mutableText: String,
            postMutableText: String,
            buttonText: String
        ) {
            self.state = state
            self.titleText = titleText
            self.subtitleText = subtitleText
            self.preMutableText = preMutableText
            self.mutableText = mutableText
            self.postMutableText = postMutableText
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
            createBodyText()
                .fixedSize(horizontal: false, vertical: true)
                .foregroundColor(Color.white)
            SecondaryButton(
                titleText: viewModel.buttonText, tapAction: {},
                color: viewModel.state == .enabled ? Color.darkBlue : Color.darkRed
            )
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 28)
        .background(viewModel.state == .enabled ? Color.primaryBlue: Color.alertRed)
        .cornerRadius(18)
        .shadow(radius: 5)
    }
    
    private func createBodyText() -> Text {
        return Text("\(self.viewModel.preMutableText)") +
            Text("\(self.viewModel.mutableText)")
                .bold() +
            Text("\(self.viewModel.postMutableText)")
    }
}

struct ContentCard_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = ContentCard.ViewModel(
            state: .enabled,
            titleText: "8:10am",
            subtitleText: "May 17",
            preMutableText: "Open the app in ",
            mutableText: "07:18:36",
            postMutableText: " or your sleepyhead message gets sent.",
            buttonText: "Change awake confirmation time"
        )
        
        return ContentCard(viewModel: .constant(viewModel))
    }
}
