//
//  ScheduleViewPresenter.swift
//  Dozy
//
//  Created by Andrew Daniel on 7/19/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import SwiftUI

let pushNotificationIdentifier = "dozy_awake_confirmation_alert"

protocol ScheduleViewPresenter: SwitchViewDelegate, MessageFormDelegate, HeaderMainDelegate, OverlayCardDelegate {
    func onMessageActionButtonTapped()
    func navigateToMessageForm() -> MessageFormView
    
    func onEditAwakeConfirmationTimeButtonTapped()
    func onTimePickerDoneButtonTapped()
    func onTimePickerCancelButtonTapped()
    
    func onChangeAwakeConfirmationTimeTapped()
}

class SchedulePresenter: ScheduleViewPresenter {
    
    private var viewModel: ScheduleViewModel
    private let userDefaults: ScheduleUserDefaults
    private var schedule: Schedule
    
    private var secondsUntilAwakeConfirmationTime: Int
    private let awakeConfirmationTimer: Timeable
    
    private let networkService: NetworkRequesting
    private let keychain: SecureStorable
    private let userNotificationCenter: UserNotificationCenter
    
    private weak var navigationControllable: NavigationControllable?
    
    init(
        schedule: Schedule,
        isPostMessageSent: ScheduledMessageStatus,
        viewModel: ScheduleViewModel,
        userDefaults: ScheduleUserDefaults,
        networkService: NetworkRequesting,
        keychain: SecureStorable,
        navigationControllable: NavigationControllable?,
        awakeConfirmationTimer: Timeable,
        userNotificationCenter: UserNotificationCenter
    ) {
        self.viewModel = viewModel
        self.userDefaults = userDefaults
        self.schedule = schedule
        self.networkService = networkService
        self.keychain = keychain
        self.navigationControllable = navigationControllable
        self.awakeConfirmationTimer = awakeConfirmationTimer
        self.userNotificationCenter = userNotificationCenter
        
        let now = Current.now()
        self.secondsUntilAwakeConfirmationTime = Int(schedule.awakeConfirmationTime.timeIntervalSince(now))
        updateAwakeConfirmationTimeToNextDayIfNeeded(from: now)
        
        switch isPostMessageSent {
        case .sent, .confirmed:
            showOverlayCard(status: isPostMessageSent)
        case .notSent:
            if schedule.isActive {
                enableAwakeConfirmation()
            } else {
                disableAwakeConfirmation()
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: SceneNotification.willEnterForeground, object: nil)
    }
    
    @objc private func willEnterForeground() {
        func comparePostAwakeConfirmationTimes(from date: Date) {
            switch date.compare(schedule.sleepyheadMessagePostTime) {
            case .orderedDescending, .orderedSame:
                showOverlayCard(status: .sent)
            case .orderedAscending:
                guard now.compare(schedule.delayedAwakeConfirmationTime) == .orderedAscending else {
                    showOverlayCard(status: .confirmed)
                    return
                }
                navigateToAwakeConfirmation()
            }
        }
        
        guard schedule.isActive else { return }
        
        let now = Current.now()
        switch now.compare(schedule.awakeConfirmationTime) {
            case .orderedDescending, .orderedSame:
                comparePostAwakeConfirmationTimes(from: now)
            case .orderedAscending:
                let now = Current.now()
                self.secondsUntilAwakeConfirmationTime = Int(schedule.awakeConfirmationTime.timeIntervalSince(now))
        }
    }
    
    private func showOverlayCard(status: ScheduledMessageStatus) {
        let overlayCardText: String = {
            switch status {
            case .sent:
                return "Your message was sent you sleepyhead."
            case .confirmed:
                return "Your message will be sent in 1 minute you sleepyhead."
            case .notSent:
                preconditionFailure("Should not show overlay card if scheduled message is not sent")
            }
        }()
        
        viewModel.overlayCardText = overlayCardText
        viewModel.isShowingOverlayCard = true
        saveInactiveSchedule()
        setInactiveViewState(isSwitchLoading: false)
    }
    
    private func navigateToAwakeConfirmation() {
        let viewController = AwakeConfirmationViewBuilder(schedule: schedule, userDefaults: userDefaults, navigationControllable: navigationControllable).buildViewController()
        navigationControllable?.pushViewController(viewController, animated: true)
        navigationControllable?.viewControllers = [viewController]
        
        NotificationCenter.default.removeObserver(self)
    }
    
    private func enableAwakeConfirmation() {
        setAwakeConfirmationCountdown()
        
        awakeConfirmationTimer.startTimer(timeInterval: 1, actionBlock: updateAwakeConfirmationTimer)
        
        viewModel.awakeConfirmationCard.preMutableText = "Open the app in "
        viewModel.awakeConfirmationCard.postMutableText = " or your sleepyhead message gets sent."
    }
    
    private func disableAwakeConfirmation() {
        awakeConfirmationTimer.stopTimer()
        
        viewModel.awakeConfirmationCard.preMutableText = "Awake confirmation timer is currently disabled."
        viewModel.awakeConfirmationCard.mutableText = ""
        viewModel.awakeConfirmationCard.postMutableText = ""
    }
    
    private func updateAwakeConfirmationTimer() {
        if secondsUntilAwakeConfirmationTime > 0 {
            setAwakeConfirmationCountdown()
            secondsUntilAwakeConfirmationTime -= 1
        } else {
            awakeConfirmationTimer.stopTimer()
            navigateToAwakeConfirmation()
        }
    }
    
    private func setAwakeConfirmationCountdown() {
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
        userDefaults.save(schedule)
    }
    
    private func updateAwakeConfirmationText(with schedule: Schedule) {
        viewModel.awakeConfirmationCard.titleText = schedule.awakeConfirmationDateText
        viewModel.awakeConfirmationCard.subtitleText = schedule.awakeConfirmationTimeText
    }
    
    func onSwitchPositionChangedTriggered() {
        switch viewModel.state {
        case .inactive:
            switch schedule.awakeConfirmationTime.compare(Current.now()) {
            case .orderedSame, .orderedAscending:
                showErrorToast(text: "Passed date selected. Please change date.")
            case .orderedDescending:
                setActiveSchedule()
            }
        case .active:
            let minimumLeadTimeInSecondsForSettingInactiveState: TimeInterval = (15 * 60)
            let minimumLeadTimeForSettingInactiveState = schedule.awakeConfirmationTime.addingTimeInterval(-minimumLeadTimeInSecondsForSettingInactiveState)
            
            switch Current.now().compare(minimumLeadTimeForSettingInactiveState) {
            case .orderedSame, .orderedDescending:
                showErrorToast(text: "Cannot disable when timer is under 15 minutes.")
            case .orderedAscending:
                setInactiveViewState(isSwitchLoading: true)
                sendDeleteScheduledMessageRequest()
                deletePushNotification()
            }
        }
    }
    
    private func showErrorToast(text: String) {
        viewModel.errorToastText = text
        viewModel.errorToastIsShowing = true
    }
    
    private func setActiveSchedule() {
        setActiveViewState(isSwitchLoading: true)
        sendScheduleMessageRequest()
        createPushNotification()
    }
    
    private func setActiveViewState(isSwitchLoading: Bool) {
        viewModel.state = .active
        viewModel.switchPosition = (.on, isSwitchLoading)
        
        secondsUntilAwakeConfirmationTime = Int(schedule.awakeConfirmationTime.timeIntervalSince(Current.now()))
        enableAwakeConfirmation()
    }
    
    private func setInactiveViewState(isSwitchLoading: Bool) {
        viewModel.state = .inactive
        viewModel.switchPosition = (.off, isSwitchLoading)
        disableAwakeConfirmation()
    }
    
    private func sendScheduleMessageRequest() {
        guard let accessTokenData = keychain.load(key: "slack_access_token") else { return }
        let accessToken = String(decoding: accessTokenData, as: UTF8.self)
        let headers = ["Authorization": "Bearer \(accessToken)"]
        
        let requestBody = generateMessageRequestBody()
        
        guard let request = NetworkRequest(url: "https://slack.com/api/chat.scheduleMessage", httpMethod: .post, parameters: requestBody, headers: headers, contentType: .json) else { preconditionFailure("Invalid url") }
        self.networkService.performNetworkRequest(request, completion: { [weak self] (result: Result<ScheduledMessageResponse, NetworkService.RequestError>) -> Void in
            guard let self = self else { return }
            
            Current.dispatchQueue.async {
                switch result {
                case .success(let response):
                    self.schedule.scheduledMessageId = response.scheduledMessageId
                    self.userDefaults.save(self.schedule)
                    
                    self.viewModel.switchPosition = (.on, false)
                case .failure:
                    self.setInactiveViewState(isSwitchLoading: false)
                    self.showErrorToast(text: "Oops, something happened. Please try again.")
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
                    "text": [
                        "type": "plain_text",
                        "emoji": true,
                        "text": bodyText
                    ]
                ]
            }
            
            let imageBlock: [String: Any]? = message.imageUrl.map { imageUrl in
                return [
                    "type": "image",
                    "image_url": imageUrl,
                    "alt_text": "Sleepyhead Image"
                ]
            }
            
            return [textBlock, imageBlock].compactMap { return $0 }
        }()
        
        let postAtTime = schedule.sleepyheadMessagePostTime
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
        self.networkService.performNetworkRequest(request, completion: { [weak self] result in
            guard let self = self else { return }
            
            Current.dispatchQueue.async {
                switch result {
                case .success:
                    self.saveInactiveSchedule()
                    self.viewModel.switchPosition = (.off, false)
                case .failure:
                    self.showErrorToast(text: "Oops, something happened. Please try again.")
                    self.setActiveViewState(isSwitchLoading: false)
                }
            }
        })
    }
    
    private func saveInactiveSchedule() {
        self.schedule.scheduledMessageId = nil
        self.userDefaults.save(self.schedule)
    }
    
    private func createPushNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Hope you're awake sleepyhead!"
        content.body = "Confirm that you're awake before the timer runs out"
        content.sound = .default
        
        let dateComponents = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: self.schedule.awakeConfirmationTime
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: pushNotificationIdentifier, content: content, trigger: trigger)
        
        userNotificationCenter.add(request: request, completion: nil)
    }
    
    private func deletePushNotification() {
        userNotificationCenter.removePendingNotificationRequests(withIdentifiers: [pushNotificationIdentifier])
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
        userDefaults.save(schedule)
        
        updateMessageCard(with: message)
        
        self.schedule = schedule
        self.viewModel.isShowingMessageForm = false
    }
    
    func onMessageFormCancelled() {
        self.viewModel.isShowingMessageForm = false
    }
    
    private func updateMessageCard(with message: Message) {
        self.viewModel.messageCard = ScheduleViewModel.MessageCardViewModel(
            image: message.uiImage,
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
        
        let nowSecondsComponent = TimeInterval(Calendar.current.dateComponents([.second], from: now).second ?? 0)
        let updatedAwakeConfirmationTime = now.addingTimeInterval(secondsToAdd - nowSecondsComponent)
        self.updateUserDefaultsSchedule(with: updatedAwakeConfirmationTime)
        self.updateAwakeConfirmationText(with: self.schedule)
        
        self.viewModel.awakeConfirmationCard.isShowingTimePicker = false
    }
    
    func onTimePickerCancelButtonTapped() {
        self.viewModel.awakeConfirmationCard.isShowingTimePicker = false
    }
    
    func onProfileIconTapped() {
        let profileViewController = ProfileViewBuilder(navigationControllable: navigationControllable).buildViewController()
        navigationControllable?.pushViewController(profileViewController, animated: true)
    }
    
    func onChangeAwakeConfirmationTimeTapped() {
        switch self.viewModel.state {
        case .inactive:
            withAnimation {
                self.viewModel.awakeConfirmationCard.isShowingTimePicker = true
            }
        case .active:
            showErrorToast(text: "Cannot change time when timer is enabled.")
        }
    }
    
}

private struct ScheduledMessageResponse: Decodable {
    let scheduledMessageId: String
    
    enum CodingKeys: String, CodingKey {
        case scheduledMessageId = "scheduled_message_id"
    }
}

// MARK: OverlayCardDelegate
extension SchedulePresenter {
    
    func onOverlayCardDismissButtonTapped() {
        self.viewModel.isShowingOverlayCard = false
    }
    
}
