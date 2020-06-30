//
//  WorldMock.swift
//  DozyTests
//
//  Created by Andrew Daniel on 6/30/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import Foundation
@testable import Dozy

extension World {
    
    static var mock: World {
        World(
            dispatchQueue: DispatchQueueMock(),
            configuration: Current.configuration,
            window: nil
        )
    }
    
}
