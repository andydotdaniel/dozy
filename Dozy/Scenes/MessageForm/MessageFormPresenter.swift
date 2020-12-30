//
//  MessageFormPresenter.swift
//  Dozy
//
//  Created by Andrew Daniel on 7/5/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import Foundation
import Combine
import SwiftUI
import FirebaseStorage

protocol MessageFormViewPresenter {
    func didTapChannelDropdown()
    func didTapChannelItem(id: String)
    func didTapSave()
    
    func onImageUploadConfirmed()
    func onImageUploadCancelled()
    
    func onChannelFetchRetryButtonTapped()
}

class MessageFormPresenter: MessageFormViewPresenter {
    
    @ObservedObject private var viewModel: MesssageFormViewModel
    private let networkService: NetworkRequesting
    private let keychain: SecureStorable
    private weak var delegate: MessageFormDelegate?
    
    private var channelItems: [Channel] = []
    private var channelNameTextFieldSubscriber: AnyCancellable?
    private var selectedChannel: Channel?
    
    private let message: Message?
    private var accessToken: String?
    
    private var selectedImageData: Data?
    
    init(
        viewModel: MesssageFormViewModel,
        networkService: NetworkRequesting,
        keychain: SecureStorable = Keychain(),
        delegate: MessageFormDelegate?,
        message: Message?
    ) {
        self.viewModel = viewModel
        self.networkService = networkService
        self.keychain = keychain
        self.delegate = delegate
        self.selectedChannel = message?.channel
        self.message = message
        self.selectedImageData = message?.image
        
        if let accessTokenData = keychain.load(key: "slack_access_token") {
            let accessToken = String(decoding: accessTokenData, as: UTF8.self)
            self.accessToken = accessToken
            fetchChannels(accessToken: accessToken)
        }
        
        self.channelNameTextFieldSubscriber = self.viewModel.$channelNameTextFieldText
            .debounce(for: .seconds(0.150), scheduler: DispatchQueue.main)
            .sink { text in self.filterChannelItems(with: text) }
    }
    
    private func fetchChannels(accessToken: String, cursor: String? = nil) {
        let url = "https://slack.com/api/users.conversations"
        var parameters: [String: Any] = [
            "token": accessToken,
            "exclude_archived": true,
            "limit": 100,
            "types": "public_channel,private_channel"
        ]
        
        if let cursor = cursor {
            parameters["cursor"] = cursor
        }
        
        guard let networkRequest = NetworkRequest(url: url, httpMethod: .get, parameters: parameters, contentType: .urlEncodedForm) else { return }
        self.viewModel.isFetchingChannels = true
        
        networkService.peformNetworkRequest(networkRequest, completion: { [weak self] (result: Result<SlackChannelResponse, NetworkService.RequestError>) -> Void in
            guard let self = self else { return }
            
            Current.dispatchQueue.async {
                switch result {
                case .success(let response):
                    let fetchedChannelItems: [Channel] = response.channels.map { channel in
                        let isPublic = channel.isChannel && !channel.isGroup
                        return Channel(id: channel.id, isPublic: isPublic, text: channel.name)
                    }
                    self.channelItems.append(contentsOf: fetchedChannelItems)
                    
                    if let nextCursor = response.nextCursor {
                        self.fetchChannels(accessToken: accessToken, cursor: nextCursor)
                    } else {
                        self.viewModel.isFetchingChannels = false
                    }
                case .failure:
                    self.viewModel.isFetchingChannels = false
                }
            }
        })
    }
    
    func didTapChannelDropdown() {
        viewModel.isShowingChannelDropdown = true
        viewModel.filteredChannelItems = channelItems
    }
    
    func didTapChannelItem(id: String) {
        viewModel.isShowingChannelDropdown = false
        if let channel = viewModel.filteredChannelItems.first(where: { $0.id == id }) {
            viewModel.channelNameTextFieldText = channel.text
            selectedChannel = channel
        }
    }
    
    private func filterChannelItems(with text: String) {
        if text.isEmpty {
            viewModel.filteredChannelItems = channelItems
            return
        }
        
        let lowercasedText = text.lowercased()
        viewModel.filteredChannelItems = channelItems.filter { channelItem in
            channelItem.text.lowercased().contains(lowercasedText)
        }
    }
    
    func didTapSave() {
        guard let channel = self.selectedChannel else { return }
        
        self.selectedImageData = self.viewModel.selectedImage?.pngData()
        if let selectedImage = self.selectedImageData, selectedImage != message?.image {
            self.viewModel.isShowingImageUploadConfirmation = true
        } else {
            completeMessageSaving(image: self.selectedImageData, imageUrl: message?.imageUrl, channel: channel)
        }
    }
    
    private func completeMessageSaving(image: Data?, imageUrl: String?, channel: Channel) {
        let message = Message(
            image: image,
            imageUrl: imageUrl,
            bodyText: self.viewModel.bodyText,
            channel: channel
        )
        
        self.delegate?.onMessageSaved(message)
    }
    
    private func uploadImage(image: Data, completion: @escaping (Result<String, NetworkService.RequestError>) -> Void) {
        let storage = Storage.storage()
        let storageReference = storage.reference(withPath: "/images/\(Current.now().timeIntervalSinceReferenceDate).jpg")
        
        let metadata = StorageMetadata(dictionary: ["contentType": "image/jpeg"])
        storageReference.putData(image, metadata: metadata) { metadata, error in
            guard metadata != nil, error == nil else {
                completion(.failure(.unknown(message: "Failed to upload image")))
                return
            }
            
            storageReference.downloadURL(completion: { url, error in
                guard let url = url, error == nil else {
                    completion(.failure(.invalidNetworkResponse))
                    return
                }
                
                completion(.success(url.absoluteString))
            })
        }
    }
    
    func onImageUploadConfirmed() {
        guard let channel = self.selectedChannel else { return }
        if let compressedImage = self.viewModel.selectedImage?.jpegData(compressionQuality: 0.35), let selectedImage = self.selectedImageData {
            self.viewModel.isSaving = true
            uploadImage(image: compressedImage, completion: { [weak self] result in
                guard let self = self else { return }
                
                Current.dispatchQueue.async {
                    switch result {
                    case .success(let imageUrl):
                        self.completeMessageSaving(image: selectedImage, imageUrl: imageUrl, channel: channel)
                    case .failure:
                        self.viewModel.isSaving = false
                        self.viewModel.isShowingSaveError = true
                    }
                }
            })
        }
    }
    
    func onImageUploadCancelled() {
        self.viewModel.isShowingImageUploadConfirmation = false
    }
    
    func onChannelFetchRetryButtonTapped() {
        guard let accessToken = accessToken else { return }
        fetchChannels(accessToken: accessToken)
    }
    
}

private struct SlackChannel: Decodable {
    let id: String
    let name: String
    let isChannel: Bool
    let isGroup: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case isChannel = "is_channel"
        case isGroup = "is_group"
    }
}

private struct SlackChannelResponse: Decodable {
    let channels: [SlackChannel]
    let nextCursor: String?
    
    enum CodingKeys: String, CodingKey {
        case channels
        case responseMetadata = "response_metadata"
    }
    
    enum ResponseMetadataCodingKeys: String, CodingKey {
        case nextCursor = "next_cursor"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        channels = try container.decode([SlackChannel].self, forKey: .channels)
        
        let responseMetadataContainer = try container.nestedContainer(keyedBy: ResponseMetadataCodingKeys.self, forKey: .responseMetadata)
        if let nextCursor = try? responseMetadataContainer.decode(String.self, forKey: .nextCursor), nextCursor.count > 0 {
            self.nextCursor = nextCursor
        } else {
            self.nextCursor = nil
        }
    }
}

private struct FileUploadResponse: Decodable {
    let id: String
    let urlPrivate: String
    
    enum CodingKeys: String, CodingKey {
        case file = "file"
    }
    
    enum FileCodingKeys: String, CodingKey {
        case id
        case urlPrivate = "url_private"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let fileContainer = try container.nestedContainer(keyedBy: FileCodingKeys.self, forKey: .file)
        
        id = try fileContainer.decode(String.self, forKey: .id)
        urlPrivate = try fileContainer.decode(String.self, forKey: .urlPrivate)
    }
}

private struct ShareFileResponse: Decodable {
    let permalinkPublic: String
    
    enum CodingKeys: String, CodingKey {
        case file = "file"
    }
    
    enum FileCodingKeys: String, CodingKey {
        case permalinkPublic = "permalink_public"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let fileContainer = try container.nestedContainer(keyedBy: FileCodingKeys.self, forKey: .file)
        
        permalinkPublic = try fileContainer.decode(String.self, forKey: .permalinkPublic)
    }
}
