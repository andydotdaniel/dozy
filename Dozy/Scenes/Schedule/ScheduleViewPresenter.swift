//
//  ScheduleViewPresenter.swift
//  Dozy
//
//  Created by Andrew Daniel on 7/19/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import SwiftUI

private let pushNotificationIdentifier = "dozy_awake_confirmation_alert"

protocol ScheduleViewPresenter: SwitchViewDelegate, MessageFormDelegate, HeaderMainDelegate {
    func onMessageActionButtonTapped()
    func navigateToMessageForm() -> MessageFormView
    
    func onEditAwakeConfirmationTimeButtonTapped()
    func onTimePickerDoneButtonTapped()
    func onTimePickerCancelButtonTapped()
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
        
        let now = Date()
        let timeDifference = now.timeIntervalSince(schedule.awakeConfirmationTime)
        let numberOfDays: Int = {
            let secondsInADay: Int = 86400
            let days = Int(timeDifference) / secondsInADay
            return days == 0 ? 1 : days
        }()
        let secondsToNextDay: TimeInterval = 60 * 60 * (TimeInterval(numberOfDays) * 24)
        let nextDay = schedule.awakeConfirmationTime.addingTimeInterval(secondsToNextDay)
        
        updateUserDefaultsSchedule(with: nextDay)
        
        secondsUntilAwakeConfirmationTime = Int(nextDay.timeIntervalSince(date))
        
        updateAwakeConfirmationText(with: schedule)
    }
    
    private func updateUserDefaultsSchedule(with time: Date) {
        schedule.awakeConfirmationTime = time
        userDefaults.saveSchedule(schedule)
    }
    
    private func updateAwakeConfirmationText(with schedule: Schedule) {
        viewModel.awakeConfirmationCard.titleText = schedule.awakeConfirmationDateText
        viewModel.awakeConfirmationCard.subtitleText = schedule.awakeConfirmationTimeText
    }
    
    func onSwitchPositionChangedTriggered() {
        switch viewModel.state {
        case .inactive:
            let now = Date()
            if schedule.awakeConfirmationTime.compare(now) == .orderedAscending {
                viewModel.errorToastText = "Passed date selected. Please change date."
                viewModel.errorToastIsShowing = true
            } else {
                setActiveSchedule()
            }
        case .active:
            setInactiveSchedule()
        }
    }
    
    private func setActiveSchedule() {
        viewModel.state = .active
        viewModel.switchPosition = (.on, true)
        enableAwakeConfirmation()
        
        sendScheduleMessageRequest()
        createPushNotification()
    }
    
    private func setInactiveSchedule() {
        viewModel.state = .inactive
        viewModel.switchPosition = (.off, true)
        disableAwakeConfirmation()
        
        sendDeleteScheduledMessageRequest()
        deletePushNotification()
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
                    
                    self.viewModel.switchPosition = (.on, false)
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
    
    private func sendDeleteScheduledMessageRequest() {
        guard let scheduledMessageId = schedule.scheduledMessageId,
            let accessTokenData = keychain.load(key: "slack_access_token") else { return }
        let accessToken = String(decoding: accessTokenData, as: UTF8.self)
        let headers = ["Authorization": "Bearer \(accessToken)"]
        
        let parameters = [
            "channel": schedule.message.channel.id,
            "scheduled_message_id": scheduledMessageId
        ]
        
        guard let request = NetworkRequest(url: "https://slack.com/api/chat.deleteScheduledMessage", httpMethod: .post, parameters: parameters, headers: headers, contentType: .json) else { preconditionFailure("Invalid url") }
        self.networkService.peformNetworkRequest(request, completion: { [weak self] result in
            guard let self = self else { return }
            
            Current.dispatchQueue.async {
                switch result {
                case .success:
                    self.schedule.scheduledMessageId = nil
                    self.userDefaults.saveSchedule(self.schedule)
                    
                    self.viewModel.switchPosition = (.off, false)
                case .failure:
                    // TODO: Handle failure
                    break
                }
            }
        })
    }
    
    private func createPushNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Hope you're awake sleepyhead!"
        content.body = "Confirm that you're awake before the timer runs out"
        
        let dateComponents = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: self.schedule.awakeConfirmationTime
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: pushNotificationIdentifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
            if error != nil {
                // TODO: Handle errors
            }
        })
    }
    
    private func deletePushNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [pushNotificationIdentifier])
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
    
    func onEditAwakeConfirmationTimeButtonTapped() {
        self.viewModel.awakeConfirmationCard.isShowingTimePicker = true
    }
    
    func onTimePickerDoneButtonTapped() {
        func calculateMinutesDifference(_ timeA: Time, with timeB: Time) -> Int {
            let timeAMinutes = (timeA.hour * 60) + timeA.minute
            let timeBMinutes = (timeB.hour * 60) + timeB.minute
            
            return timeAMinutes - timeBMinutes
        }
        
        let updatedTimePickerDate = Time(from: self.viewModel.awakeConfirmationCard.timePickerDate)
        let now = Current.now()
        let nowTime = Time(from: now)
        
        let updatedTimePickerDateAndNowMinutesDifference = calculateMinutesDifference(updatedTimePickerDate, with: nowTime)
        
        let secondsToAdd: TimeInterval = {
            if updatedTimePickerDateAndNowMinutesDifference < 0 {
                let midnight = Time(hour: 24, minute: 00)
                let nowAndMidnightDifference = calculateMinutesDifference(midnight, with: nowTime)
                
                let secondsToAdd = (nowAndMidnightDifference * 60) + (((updatedTimePickerDate.hour * 60) + updatedTimePickerDate.minute) * 60)
                return TimeInterval(secondsToAdd)
            } else {
                return TimeInterval(updatedTimePickerDateAndNowMinutesDifference * 60)
            }
        }()
        
        let updatedAwakeConfirmationTime = now.addingTimeInterval(secondsToAdd)
        self.updateUserDefaultsSchedule(with: updatedAwakeConfirmationTime)
        self.updateAwakeConfirmationText(with: self.schedule)
        
        self.viewModel.awakeConfirmationCard.isShowingTimePicker = false
    }
    
    func onTimePickerCancelButtonTapped() {
        self.viewModel.awakeConfirmationCard.isShowingTimePicker = false
    }
    
    func onSettingsIconTapped() {
        
    }
    
}

private struct ScheduledMessageResponse: Decodable {
    let scheduledMessageId: String
    
    enum CodingKeys: String, CodingKey {
        case scheduledMessageId = "scheduled_message_id"
    }
}
