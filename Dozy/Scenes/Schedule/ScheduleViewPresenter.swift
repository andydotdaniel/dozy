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
    
    init(schedule: Schedule, viewModel: ScheduleViewModel, userDefaults: ScheduleUserDefaultable) {
        self.viewModel = viewModel
        self.userDefaults = userDefaults
        self.schedule = schedule
        
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
    
    func onSwitchPositionChanged(position: Switch.Position) {
        viewModel.state = position == .on ? .active : .inactive
        
        if position == .on {
            enableAwakeConfirmation()
        } else {
            disableAwakeConfirmation()
        }
        
        schedule.isActive = position == .on ? true : false
        userDefaults.saveSchedule(schedule)
    }
    
    func onMessageActionButtonTapped() {
        self.viewModel.isShowingMessageForm = true
    }
    
    func onMessageSaved(_ message: Message) {
        let schedule = Schedule(
            message: message,
            awakeConfirmationTime: self.schedule.awakeConfirmationTime,
            isActive: self.schedule.isActive
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
