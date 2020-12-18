//
//  TimerMock.swift
//  DozyTests
//
//  Created by Andrew Daniel on 12/18/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

@testable import Dozy
import Foundation

class TimerMock: Timeable {
    
    var actionBlock: (() -> Void)?
    
    func startTimer(timeInterval: TimeInterval, actionBlock: @escaping () -> Void) {
        self.actionBlock = actionBlock
    }
    
    var stopTimerCalled: Bool = false
    func stopTimer() {
        stopTimerCalled = true
        actionBlock = nil
    }
    
}
