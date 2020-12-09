//
//  NavigationControllableMock.swift
//  DozyTests
//
//  Created by Andrew Daniel on 12/9/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

@testable import Dozy
import UIKit

class NavigationControllableMock: NavigationControllable {
    
    var pushViewControllerCalledWithArgs: (viewController: UIViewController, animated: Bool)?
    func pushViewController(_ viewController: UIViewController, animated: Bool) {
        pushViewControllerCalledWithArgs = (viewController, animated)
    }
    
}
