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
            ZStack {
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
                            Button(action: {
                                self.presenter.didTapChannelItem(id: channelItem.id)
                            }, label: {
                                ChannelView(isPublic: channelItem.isPublic, text: channelItem.text)
                                    .padding(.vertical, 16)
                            })
                        }
                        .offset(y: -24)
                    } else {
                        VStack(alignment: .leading, spacing: 16) {
                            MultilineTextField(placeholderText: "Compose message", text: $viewModel.bodyText)
                            ImagePickerButton(selectedImage: $viewModel.selectedImage)
                                .animation(.easeOut)
                                .onTapGesture {
                                   self.viewModel.isShowingImagePicker.toggle()
                                }
                        }
                        .padding(.horizontal, 24)
                        .offset(y: -12)
                    }
                }
                if viewModel.isSaving {
                    ZStack {
                        Color.white
                            .opacity(0.60)
                        HStack(alignment: .center, spacing: 12) {
                            Spinner(strokeColor: Color.primaryBlue)
                            Text("Saving message...")
                                .font(.body)
                        }
                    }
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
                }.disabled(!viewModel.isSaveButtonEnabled)
            )
            .alert(isPresented: $viewModel.isShowingImageUploadConfirmation, content: {
                let confirmButton: Alert.Button = .default(Text("Yes"), action: {
                    self.presenter.onImageUploadConfirmed()
                })
                
                let cancelButton: Alert.Button = .default(Text("No"), action: {
                    self.presenter.onImageUploadCancelled()
                })
                
                return Alert(
                    title: Text("Confirm Image Upload"),
                    message: Text("The selected image will be uploaded to Slack with public viewing permissions. Do you want to save your message and upload the image?"),
                    primaryButton: cancelButton,
                    secondaryButton: confirmButton
                )
            })
        }
    }
}

struct MessageFormView_Previews: PreviewProvider {
    
    static var previews: some View {
        let viewModel = MesssageFormViewModel(navigationBarTitle: "Add Message", message: nil)
        let presenter = MessageFormPresenter(viewModel: viewModel, networkService: NetworkService(), delegate: nil, message: nil)
        return MessageFormView(viewModel: viewModel, presenter: presenter)
    }
}
