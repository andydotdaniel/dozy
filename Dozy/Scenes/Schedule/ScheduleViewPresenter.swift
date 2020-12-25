//
//  ScheduleViewPresenter.swift
//  Dozy
//
//  Created by Andrew Daniel on 7/19/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import SwiftUI

private let pushNotificationIdentifier = "dozy_awake_confirmation_alert"
let awakeConfirmationDelay: TimeInterval = 90

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
    
    private weak var navigationControllable: NavigationControllable?
    
    init(
        schedule: Schedule,
        isPostMessageSent: Bool,
        viewModel: ScheduleViewModel,
        userDefaults: ScheduleUserDefaults,
        networkService: NetworkRequesting,
        keychain: SecureStorable,
        navigationControllable: NavigationControllable?,
        awakeConfirmationTimer: Timeable
    ) {
        self.viewModel = viewModel
        self.userDefaults = userDefaults
        self.schedule = schedule
        self.networkService = networkService
        self.keychain = keychain
        self.navigationControllable = navigationControllable
        self.awakeConfirmationTimer = awakeConfirmationTimer
        
        let now = Current.now()
        self.secondsUntilAwakeConfirmationTime = Int(schedule.awakeConfirmationTime.timeIntervalSince(now))
        updateAwakeConfirmationTimeToNextDayIfNeeded(from: now)
        
        if isPostMessageSent {
            showOverlayCard()
        } else if schedule.isActive {
            enableAwakeConfirmation()
        } else {
            disableAwakeConfirmation()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: SceneNotification.willEnterForeground, object: nil)
    }
    
    @objc private func willEnterForeground() {
        let now = Current.now()
        switch now.compare(schedule.awakeConfirmationTime) {
            case .orderedDescending, .orderedSame:
                guard now.compare(schedule.sleepyheadMessagePostTime) == .orderedAscending else {
                    showOverlayCard()
                    return
                }
                navigateToAwakeConfirmation()
            case .orderedAscending:
                break
        }
    }
    
    private func showOverlayCard() {
        viewModel.isShowingOverlayCard = true
        saveInactiveSchedule()
        setInactiveViewState(isSwitchLoading: false)
    }
    
    private func navigateToAwakeConfirmation() {
        let viewController = AwakeConfirmationViewBuilder(schedule: schedule, navigationControllable: navigationControllable).buildViewController()
        navigationControllable?.pushViewController(viewController, animated: true)
        navigationControllable?.viewControllers = [viewController]
        
        NotificationCenter.default.removeObserver(self)
    }
    
    private func enableAwakeConfirmation() {
        setAwakeConfirmationCountdown(from: secondsUntilAwakeConfirmationTime)
        
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
            setAwakeConfirmationCountdown(from: secondsUntilAwakeConfirmationTime)
            secondsUntilAwakeConfirmationTime -= 1
        } else {
            awakeConfirmationTimer.stopTimer()
            navigateToAwakeConfirmation()
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
                viewModel.errorToastText = "Passed date selected. Please change date."
                viewModel.errorToastIsShowing = true
            case .orderedDescending:
                setActiveSchedule()
            }
        case .active:
            setInactiveViewState(isSwitchLoading: true)
            sendDeleteScheduledMessageRequest()
            deletePushNotification()
        }
    }
    
    private func setActiveSchedule() {
        viewModel.state = .active
        viewModel.switchPosition = (.on, true)
        
        secondsUntilAwakeConfirmationTime = Int(schedule.awakeConfirmationTime.timeIntervalSince(Current.now()))
        enableAwakeConfirmation()
        
        sendScheduleMessageRequest()
        createPushNotification()
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
        self.networkService.peformNetworkRequest(request, completion: { [weak self] (result: Result<ScheduledMessageResponse, NetworkService.RequestError>) -> Void in
            guard let self = self else { return }
            
            Current.dispatchQueue.async {
                switch result {
                case .success(let response):
                    self.schedule.scheduledMessageId = response.scheduledMessageId
                    self.userDefaults.save(self.schedule)
                    
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
        
        // Add additional seconds delay to awake confirmation time because of the timer we show
        // in AwakeConfirmationView while the user confirms they are awake.
        let postAtTime = schedule.awakeConfirmationTime.addingTimeInterval(awakeConfirmationDelay)
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
                    self.saveInactiveSchedule()
                    self.viewModel.switchPosition = (.off, false)
                case .failure:
                    // TODO: Handle failure
                    break
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
        userDefaults.save(schedule)
        
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
            viewModel.errorToastText = "Cannot change time when timer is enabled."
            viewModel.errorToastIsShowing = true
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
