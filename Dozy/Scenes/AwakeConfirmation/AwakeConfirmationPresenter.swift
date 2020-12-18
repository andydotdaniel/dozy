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
    
    private var viewModel: AwakeConfirmationViewModel
    
    private let networkService: NetworkRequesting
    private let keychain: SecureStorable
    private let userDefaults: ScheduleUserDefaults
    private weak var navigationControllable: NavigationControllable?
    
    private var secondsLeftTimer: Timer?
    
    private let savedSchedule: Schedule
    
    init(
        viewModel: AwakeConfirmationViewModel,
        networkService: NetworkRequesting,
        keychain: SecureStorable,
        userDefaults: ScheduleUserDefaults,
        savedSchedule: Schedule,
        navigationControllable: NavigationControllable?
    ) {
        self.viewModel = viewModel
        self.networkService = networkService
        self.keychain = keychain
        self.userDefaults = userDefaults
        self.savedSchedule = savedSchedule
        self.navigationControllable = navigationControllable
        
        setSecondsLeftTimer()
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: SceneNotification.willEnterForeground, object: nil)
    }
    
    @objc private func willEnterForeground() {
        let secondsLeft = Int(savedSchedule.sleepyheadMessagePostTime.timeIntervalSince(Current.now()))
        viewModel.secondsLeft = secondsLeft
    }
    
    private func setSecondsLeftTimer() {
        secondsLeftTimer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(updateSecondsLeftTimer),
            userInfo: nil,
            repeats: true
        )
    }
    
    @objc private func updateSecondsLeftTimer() {
        if viewModel.secondsLeft >= 1 {
            viewModel.secondsLeft -= 1
        } else {
            secondsLeftTimer?.invalidate()
        }
    }
    
    func onSliderReachedEnd() {
        cancelScheduledMessage()
    }
    
    private func cancelScheduledMessage() {
        guard let scheduledMessageId = savedSchedule.scheduledMessageId else { return }
        guard let accessTokenData = keychain.load(key: "slack_access_token") else { return }
        let accessToken = String(decoding: accessTokenData, as: UTF8.self)
        
        guard let request = NetworkRequest(
            url: "https://slack.com/api/chat.deleteScheduledMessage",
            httpMethod: .post,
            parameters: ["channel": savedSchedule.message.channel.id, "scheduled_message_id": scheduledMessageId],
            headers: ["Authorization": "Bearer \(accessToken)"],
            contentType: .json
        ) else { preconditionFailure("Invalid url") }
        networkService.peformNetworkRequest(request, completion: { [weak self] result in
            guard let self = self else { return }
            
            Current.dispatchQueue.async {
                switch result {
                case .success:
                    var updatedSchedule = self.savedSchedule
                    updatedSchedule.scheduledMessageId = nil
                    self.userDefaults.save(updatedSchedule)
                    
                    self.navigateToSchedule(with: updatedSchedule)
                case .failure:
                    // TODO: Handle failure
                    break
                }
            }
        })
    }
    
    private func navigateToSchedule(with schedule: Schedule) {
        let scheduleViewController = ScheduleViewBuilder(schedule: schedule, navigationControllable: navigationControllable).buildViewController()
        navigationControllable?.pushViewController(scheduleViewController, animated: true)
        navigationControllable?.viewControllers = [scheduleViewController]
    }
    
}
