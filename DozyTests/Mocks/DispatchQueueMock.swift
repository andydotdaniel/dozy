//
//  DispatchQueueMock.swift
//  DozyTests
//
//  Created by Andrew Daniel on 6/30/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import Foundation
@testable import Dozy

struct DispatchQueueMock: DispatchQueueable {
    
    func async(block: @escaping () -> Void) {
        block()
    }
    
}
