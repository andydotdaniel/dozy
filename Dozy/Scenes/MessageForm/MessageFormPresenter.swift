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
    private var accessToken: String?
    
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
        func completeMessageSaving(image: Data?, imageUrl: String?, channel: Channel) {
            let message = Message(
                image: image,
                imageUrl: imageUrl,
                bodyText: self.viewModel.bodyText,
                channel: channel
            )
            
            delegate?.onMessageSaved(message)
        }
        
        guard let channel = self.selectedChannel else { return }
        
        let selectedImage = self.viewModel.selectedImage?.pngData()
        if let selectedImage = selectedImage, selectedImage != message?.image,
           let compressedImage = self.viewModel.selectedImage?.jpegData(compressionQuality: 0.35)  {
            self.viewModel.isSaving = true
            uploadImage(image: compressedImage, completion: { result in
                switch result {
                case .success(let imageUrl):
                    completeMessageSaving(image: selectedImage, imageUrl: imageUrl, channel: channel)
                case .failure:
                    // Handle Failure
                    break
                }
            })
        } else {
            completeMessageSaving(image: selectedImage, imageUrl: message?.imageUrl, channel: channel)
        }
    }
    
    private func uploadImage(image: Data, completion: @escaping (Result<String, NetworkService.RequestError>) -> Void) {
        guard let accessToken = self.accessToken, let url = URL(string: "https://slack.com/api/files.upload") else { return }
        let headers = ["Authorization": "Bearer \(accessToken)"]
        
        networkService.performImageUpload(for: image, with: url, headers: headers, completion: { [weak self] (result: Result<FileUploadResponse, NetworkService.RequestError>) in
            switch result {
            case .success(let response):
                self?.makeImagePublic(imageId: response.id, imageUrl: response.urlPrivate, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
    
    private func makeImagePublic(imageId: String, imageUrl: String, completion: @escaping (Result<String, NetworkService.RequestError>) -> Void) {
        guard let accessToken = self.accessToken else {
            completion(.failure(.unknown(message: "Access token not available")))
            return
        }
        let url = "https://slack.com/api/files.sharedPublicURL"
        let headers = ["Authorization": "Bearer \(accessToken)"]
        let parameters = ["file": imageId]
        
        guard let request = NetworkRequest(url: url, httpMethod: .post, parameters: parameters, headers: headers) else {
            completion(.failure(.unknown(message: "Unable to create network request")))
            return
        }
        networkService.peformNetworkRequest(request, completion: { (result: Result<ShareFileResponse, NetworkService.RequestError>) in
            switch result {
            case .success(let response):
                let linkSegments = response.permalinkPublic.split(separator: "-")
                guard let imagePublicSecret = linkSegments.last else {
                    completion(.failure(.invalidNetworkResponse))
                    return
                }
                
                let publicDirectImageUrl = imageUrl + "?pub_secret=\(imagePublicSecret)"
                completion(.success(publicDirectImageUrl))
            case .failure(let error):
                completion(.failure(error))
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
