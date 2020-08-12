//
//  MessageFormView.swift
//  Dozy
//
//  Created by Andrew Daniel on 6/30/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import SwiftUI

struct MessageFormView: View {
    
    @ObservedObject var viewModel: MesssageFormViewModel
    var presenter: MessageFormViewPresenter
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 30) {
                VStack {
                    TextField("Slack channel or conversation", text: $viewModel.channelNameTextFieldText)
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
                    List(viewModel.filteredChannelItems) { channelItem in
                        ChannelView(isPublic: channelItem.isPublic, text: channelItem.text)
                            .padding(.vertical, 16)
                            .onTapGesture {
                                self.presenter.didTapChannelItem(id: channelItem.id)
                            }
                    }
                    .offset(y: -24)
                } else {
                    VStack(alignment: .leading, spacing: 16) {
                        MultilineTextField(placeholderText: "Compose message", text: $viewModel.bodyText)
                        ImagePickerButton(selectedImage: $viewModel.selectedImage)
                            .offset(y: -self.viewModel.keyboardHeight)
                            .animation(.easeOut)
                            .onTapGesture {
                               self.viewModel.isShowingImagePicker.toggle()
                            }
                    }
                    .padding(.horizontal, 24)
                    .offset(y: -12)
                }
            }
            .sheet(isPresented: $viewModel.isShowingImagePicker) {
                if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                    ImagePickerView(selectedImage: self.$viewModel.selectedImage)
                }
            }
            .padding(.top, 30)
            .navigationBarTitle(Text(viewModel.navigationBarTitle), displayMode: .inline)
            .navigationBarItems(
                trailing: Button("Save") {
                    self.presenter.didTapSave()
                }
            )
        }
    }
}

struct MessageFormView_Previews: PreviewProvider {
    
    static var previews: some View {
        let viewModel = MesssageFormViewModel(navigationBarTitle: "Add Message", message: nil)
        let presenter = MessageFormPresenter(viewModel: viewModel, networkService: NetworkService(), delegate: nil, channel: nil)
        return MessageFormView(viewModel: viewModel, presenter: presenter)
    }
}
