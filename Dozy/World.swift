//
//  World.swift
//  Dozy
//
//  Created by Andrew Daniel on 6/15/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import Foundation
import UIKit

struct World {
    var dispatchQueue: DispatchQueueable = DispatchQueue.main
    var configuration: Configuration = Configuration.create()
    weak var window: UIWindow?
}

var Current = World()
