//
//  MessageFormView.swift
//  Dozy
//
//  Created by Andrew Daniel on 6/30/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import Combine
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
    @Published var isShowingChannelDropdown: Bool
    @Published var channelItems: [ChannelItem]
    
    @Published var keyboardHeight: CGFloat
    private var keyboardListener: KeyboardListener
    private var keyboardListenerSink: AnyCancellable?
    
    init(navigationBarTitle: String, channelName: String = "") {
        self.navigationBarTitle = navigationBarTitle
        self.channelName = channelName
        self.channelNameTextFieldColor = Color.placeholderGray
        self.keyboardHeight = 0
        
        self.isShowingChannelDropdown = false
        self.channelItems = [
            ChannelItem(isPublic: true, text: "Channel 2"),
            ChannelItem(isPublic: true, text: "Channel 3")
        ]
        
        let keyboardListener = KeyboardListener()
        self.keyboardListener = keyboardListener
        self.keyboardListenerSink = keyboardListener.$keyboardHeight.sink { self.keyboardHeight = $0 }
    }
}

struct MessageFormView: View {
    
    @ObservedObject var viewModel: MesssageFormViewModel
    var presenter: MessageFormViewPresenter
    
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
                    .onTapGesture {
                        self.presenter.didTapChannelDropdown()
                    }
                }
                .padding(.horizontal, 24)
                Divider()
                    .foregroundColor(Color.borderGray)
                if viewModel.isShowingChannelDropdown {
                    List(viewModel.channelItems) { channelItem in
                        ChannelItemView(content: channelItem)
                            .padding(.vertical, 16)
                    }
                } else {
                    VStack(alignment: .leading, spacing: 16) {
                        MultilineTextField(placeholderText: "Compose message")
                        AlternativeImageButton(imageName: "IconImagePlaceholder", titleText: "Add image")
                            .padding(.bottom, self.viewModel.keyboardHeight)
                            .animation(.easeOut)
                    }
                    .padding(.horizontal, 24)
                    .offset(y: -12)
                }
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
        let presenter = MessageFormPresenter(viewModel: viewModel)
        return MessageFormView(viewModel: viewModel, presenter: presenter)
    }
}
