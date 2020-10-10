//
//  AwakeConfirmationPresenter.swift
//  Dozy
//
//  Created by Andrew Daniel on 10/10/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import Foundation

protocol AwakeConfirmationViewPresenter: SliderDelegate {}

class AwakeConfirmationPresenter: AwakeConfirmationViewPresenter {
    
    private let networkService: NetworkRequesting
    private let keychain: SecureStorable
    private let userDefaults: ScheduleUserDefaultable
    
    init(networkService: NetworkRequesting, keychain: SecureStorable, userDefaults: ScheduleUserDefaultable) {
        self.networkService = networkService
        self.keychain = keychain
        self.userDefaults = userDefaults
    }
    
    func onSliderReachedEnd() {
        cancelScheduledMessage()
    }
    
    private func cancelScheduledMessage() {
        guard let schedule = userDefaults.loadSchedule(), let scheduledMessageId = schedule.scheduledMessageId else { return }
        guard let accessTokenData = keychain.load(key: "slack_access_token") else { return }
        let accessToken = String(decoding: accessTokenData, as: UTF8.self)
        
        guard let request = NetworkRequest(
            url: "/slack.com/api/chat.deleteScheduledMessage",
            httpMethod: .post,
            parameters: ["channel": schedule.message.channel.id, "scheduled_message_id": scheduledMessageId],
            headers: ["Authorization": "Bearer \(accessToken)"],
            contentType: .json
        ) else { preconditionFailure("Invalid url") }
        networkService.peformNetworkRequest(request, completion: { [weak self] result in
            guard let self = self else { return }
            
            Current.dispatchQueue.async {
                switch result {
                case .success:
                    var updatedSchedule = schedule
                    updatedSchedule.scheduledMessageId = nil
                    
                    self.userDefaults.saveSchedule(updatedSchedule)
                case .failure:
                    // TODO: Handle failure
                    break
                }
            }
        })
    }
    
}
