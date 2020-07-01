//
//  MessageFormView.swift
//  Dozy
//
//  Created by Andrew Daniel on 6/30/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import SwiftUI

class MesssageFormViewModel: ObservableObject {
    let navigationBarTitle: String
    @Published var channelName: String {
        didSet {
            if channelName.isEmpty {
                channelNameTextFieldColor = Color.placeholderGray
            } else {
                channelNameTextFieldColor = Color.black
            }
        }
    }
    @Published var channelNameTextFieldColor: Color
    
    init(navigationBarTitle: String, channelName: String = "") {
        self.navigationBarTitle = navigationBarTitle
        self.channelName = channelName
        self.channelNameTextFieldColor = Color.placeholderGray
    }
}

struct MessageFormView: View {
    
    @ObservedObject var viewModel: MesssageFormViewModel
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 30) {
                VStack {
                    TextField("Slack channel or conversation", text: $viewModel.channelName)
                    .font(.system(size: 16, weight: .semibold, design: .default))
                    .foregroundColor(viewModel.channelNameTextFieldColor)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.secondaryGray)
                    .cornerRadius(24)
                }
                .padding(.horizontal, 24)
                Divider()
                    .foregroundColor(Color.borderGray)
                VStack(alignment: .leading, spacing: 16) {
                    MultilineTextField(placeholderText: "Compose message")
                    AlternativeImageButton(imageName: "IconImagePlaceholder", titleText: "Add image")
                }
                .padding(.horizontal, 24)
                .offset(y: -12)
            }
            .padding(.top, 30)
            .navigationBarTitle(Text(viewModel.navigationBarTitle), displayMode: .inline)
            .navigationBarItems(
                trailing: Button("Save") {}
            )
        }
    }
}

struct MessageFormView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = MesssageFormViewModel(navigationBarTitle: "Add Message")
        return MessageFormView(viewModel: viewModel)
    }
}
