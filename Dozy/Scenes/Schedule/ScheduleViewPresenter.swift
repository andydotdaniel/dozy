//
//  ScheduleViewPresenter.swift
//  Dozy
//
//  Created by Andrew Daniel on 7/19/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import SwiftUI

protocol ScheduleViewPresenter: SwitchViewDelegate, MessageFormDelegate {
    func onMessageActionButtonTapped()
    func navigateToMessageForm() -> MessageFormView
}

class SchedulePresenter: ScheduleViewPresenter {
    
    private var viewModel: ScheduleViewModel
    private let userDefaults: ScheduleUserDefaultable
    private var schedule: Schedule
    
    private var secondsUntilAwakeConfirmationTime: Int
    private var awakeConfirmationTimer: Timer?
    
    private let networkService: NetworkRequesting
    private let keychain: SecureStorable
    
    init(
        schedule: Schedule,
        viewModel: ScheduleViewModel,
        userDefaults: ScheduleUserDefaultable,
        networkService: NetworkRequesting,
        keychain: SecureStorable
    ) {
        self.viewModel = viewModel
        self.userDefaults = userDefaults
        self.schedule = schedule
        self.networkService = networkService
        self.keychain = keychain
        
        let now = Date()
        self.secondsUntilAwakeConfirmationTime = Int(schedule.awakeConfirmationTime.timeIntervalSince(now))
        updateAwakeConfirmationTimeToNextDayIfNeeded(from: now)
        
        if schedule.isActive {
            enableAwakeConfirmation()
        } else {
            disableAwakeConfirmation()
        }
    }
    
    private func enableAwakeConfirmation() {
        setAwakeConfirmationCountdown(from: secondsUntilAwakeConfirmationTime)
        
        awakeConfirmationTimer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(updateAwakeConfirmationTimer),
            userInfo: nil,
            repeats: true
        )
        
        viewModel.awakeConfirmationCard.preMutableText = "Open the app in "
        viewModel.awakeConfirmationCard.postMutableText = " or your sleepyhead message gets sent."
    }
    
    private func disableAwakeConfirmation() {
        awakeConfirmationTimer?.invalidate()
        
        viewModel.awakeConfirmationCard.preMutableText = "Awake confirmation timer is currently disabled."
        viewModel.awakeConfirmationCard.mutableText = ""
        viewModel.awakeConfirmationCard.postMutableText = ""
    }
    
    @objc private func updateAwakeConfirmationTimer() {
        if secondsUntilAwakeConfirmationTime > 0 {
            setAwakeConfirmationCountdown(from: secondsUntilAwakeConfirmationTime)
            secondsUntilAwakeConfirmationTime -= 1
        } else {
            awakeConfirmationTimer?.invalidate()
        }
    }
    
    private func setAwakeConfirmationCountdown(from seconds: Int) {
        func secondsToHoursMinutesSeconds (seconds : Int) -> (hours: Int, minutes: Int, seconds: Int) {
            return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
        }
        
        let time = secondsToHoursMinutesSeconds(seconds: self.secondsUntilAwakeConfirmationTime)
        
        let hoursString = time.hours < 10 ? "0\(time.hours)" : "\(time.hours)"
        let minutesString = time.minutes < 10 ? "0\(time.minutes)" : "\(time.minutes)"
        let secondsString = time.seconds < 10 ? "0\(time.seconds)" : "\(time.seconds)"
        
        viewModel.awakeConfirmationCard.mutableText = "\(hoursString):\(minutesString):\(secondsString)"
    }
    
    private func updateAwakeConfirmationTimeToNextDayIfNeeded(from date: Date) {
        guard secondsUntilAwakeConfirmationTime < 0 else { return }
        
        let oneDayInSeconds: TimeInterval = 60 * 60 * 24
        let nextDay = schedule.awakeConfirmationTime.addingTimeInterval(oneDayInSeconds)
        
        schedule.awakeConfirmationTime = nextDay
        userDefaults.saveSchedule(schedule)
        
        secondsUntilAwakeConfirmationTime = Int(nextDay.timeIntervalSince(date))
        
        viewModel.awakeConfirmationCard.titleText = schedule.awakeConfirmationDateText
        viewModel.awakeConfirmationCard.subtitleText = schedule.awakeConfirmationTimeText
    }
    
    func onSwitchPositionChangedTriggered() {
        viewModel.switchPosition = .loading
        
        if viewModel.state == .inactive {
            sendScheduleMessageRequest()
        } else {
            disableAwakeConfirmation()
        }
    }
    
    private func sendScheduleMessageRequest() {
        guard let accessTokenData = keychain.load(key: "slack_access_token") else { return }
        let accessToken = String(decoding: accessTokenData, as: UTF8.self)
        let headers = ["Authorization": "Bearer \(accessToken)"]
        
        let requestBody = generateMessageRequestBody()
        
        guard let request = NetworkRequest(url: "https://slack.com/api/chat.scheduleMessage", httpMethod: .post, parameters: requestBody, headers: headers, contentType: .json) else { preconditionFailure("Invalid url") }
        self.networkService.peformNetworkRequest(request, completion: { [weak self] (result: Result<ScheduledMessageResponse, NetworkService.RequestError>) -> Void in
            guard let self = self else { return }
            
            Current.dispatchQueue.async {
                switch result {
                case .success(let response):
                    self.schedule.scheduledMessageId = response.scheduledMessageId
                    self.userDefaults.saveSchedule(self.schedule)
                    
                    self.enableAwakeConfirmation()
                    self.viewModel.state = .active
                    self.viewModel.switchPosition = .on
                case .failure:
                    // TODO: Handle failure
                    break
                }
            }
        })
    }
    
    private func generateMessageRequestBody() -> [String: Any] {
        let message = schedule.message
        
        let blocks: [[String: Any]] = {
            let textBlock: [String: Any]? = message.bodyText.map { bodyText in
                return [
                    "type": "section",
                    "fields": [
                        [
                            "type": "plain_text",
                            "emoji": true,
                            "text": bodyText
                        ]
                    ]
                ]
            }
            
            return [textBlock].compactMap { return $0 }
        }()
        
        // Add an additional 30 seconds to awake confirmation time because of the 30 second timer we show
        // in AwakeConfirmationView while the user confirms they are awake.
        let postAtTime = schedule.awakeConfirmationTime.addingTimeInterval(30)
        return [
            "channel": message.channel.id,
            "text": "I overslept!",
            "post_at": postAtTime.timeIntervalSince1970,
            "blocks": blocks
        ]
    }
    
    func onMessageActionButtonTapped() {
        self.viewModel.isShowingMessageForm = true
    }
    
    func onMessageSaved(_ message: Message) {
        let schedule = Schedule(
            message: message,
            awakeConfirmationTime: self.schedule.awakeConfirmationTime,
            scheduledMessageId: self.schedule.scheduledMessageId
        )
        userDefaults.saveSchedule(schedule)
        
        updateMessageCard(with: message)
        
        self.schedule = schedule
        self.viewModel.isShowingMessageForm = false
    }
    
    private func updateMessageCard(with message: Message) {
        let image = message.image.map { UIImage(data: $0) } ?? nil
        self.viewModel.messageCard = ScheduleViewModel.MessageCardViewModel(
            image: image,
            bodyText: message.bodyText,
            channel: (isPublic: message.channel.isPublic, text: message.channel.text),
            actionButtonTitle: self.viewModel.messageCard.actionButtonTitle
        )
    }
    
    func navigateToMessageForm() -> MessageFormView {
        MessageFormViewBuilder(message: self.schedule.message, delegate: self).build()
    }
    
}

private struct ScheduledMessageResponse: Decodable {
    let scheduledMessageId: String
    
    enum CodingKeys: String, CodingKey {
        case scheduledMessageId = "scheduled_message_id"
    }
}
