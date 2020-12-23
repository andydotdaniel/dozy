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

protocol MessageFormViewPresenter {
    func didTapChannelDropdown()
    func didTapChannelItem(id: String)
    func didTapSave()
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
        
        guard let accessTokenData = keychain.load(key: "slack_access_token") else { return }
        let accessToken = String(decoding: accessTokenData, as: UTF8.self)
        fetchChannels(accessToken: accessToken)
        
        self.channelNameTextFieldSubscriber = self.viewModel.$channelNameTextFieldText
            .debounce(for: .seconds(0.150), scheduler: DispatchQueue.main)
            .sink { text in self.filterChannelItems(with: text) }
    }
    
    private func fetchChannels(accessToken: String, cursor: String? = nil) {
        let url = "https://slack.com/api/conversations.list"
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
        networkService.peformNetworkRequest(networkRequest, completion: { [weak self] (result: Result<SlackChannelResponse, NetworkService.RequestError>) -> Void in
            guard let self = self else { return }
            
            Current.dispatchQueue.async {
                switch result {
                case .success(let response):
                    self.channelItems = response.channels.map { channel in
                        let isPublic = channel.isChannel && !channel.isGroup
                        return Channel(id: channel.id, isPublic: isPublic, text: channel.name)
                    }
                case .failure:
                    break
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
        
        let selectedImage = self.viewModel.selectedImage?.jpegData(compressionQuality: 0.35)
        if let selectedImage = selectedImage, selectedImage != message?.image {
            uploadImage(image: selectedImage)
        }
        
        let message = Message(
            image: selectedImage,
            bodyText: self.viewModel.bodyText,
            channel: channel
        )
        
        delegate?.onMessageSaved(message)
    }
    
    private func uploadImage(image: Data) {
        guard let accessTokenData = keychain.load(key: "slack_access_token"), let url = URL(string: "https://slack.com/api/files.upload") else { return }
        let accessToken = String(decoding: accessTokenData, as: UTF8.self)
        let headers = ["Authorization": "Bearer \(accessToken)"]
        
        networkService.performImageUpload(for: image, with: url, headers: headers, completion: { [weak self] (result: Result<FileUploadResponse, NetworkService.RequestError>) -> Void in
            switch result {
            case .success:
                break
            case .failure:
                break
            }
        })
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
    let nextCursor: String
    
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
        nextCursor = try responseMetadataContainer.decode(String.self, forKey: .nextCursor)
    }
}

private struct FileUploadResponse: Decodable {
    let url: String
    
    enum CodingKeys: String, CodingKey {
        case file = "file"
    }
    
    enum FileCodingKeys: String, CodingKey {
        case url = "url_private"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let fileContainer = try container.nestedContainer(keyedBy: FileCodingKeys.self, forKey: .file)
        
        url = try fileContainer.decode(String.self, forKey: .url)
    }
}
