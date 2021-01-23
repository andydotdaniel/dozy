//
//  ActionTimer.swift
//  Dozy
//
//  Created by Andrew Daniel on 12/18/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import Foundation

protocol Timeable {
    func startTimer(timeInterval: TimeInterval, actionBlock: @escaping () -> Void)
    func stopTimer()
}

class ActionTimer: Timeable {
    
    private weak var timer: Timer?
    private var actionBlock: (() -> Void)?
    
    func startTimer(timeInterval: TimeInterval, actionBlock: @escaping () -> Void) {
        timer = Timer.scheduledTimer(
            timeInterval: timeInterval,
            target: self,
            selector: #selector(onTimerUpdated),
            userInfo: nil,
            repeats: true
        )
        
        self.actionBlock = actionBlock
    }
    
    func stopTimer() {
        timer?.invalidate()
        actionBlock = nil
    }
    
    @objc private func onTimerUpdated() {
        actionBlock?()
    }
    
}
