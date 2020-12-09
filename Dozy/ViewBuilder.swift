//
//  ViewBuilder.swift
//  Dozy
//
//  Created by Andrew Daniel on 6/15/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import Foundation
import UIKit

protocol ViewBuilder {
    associatedtype View
    func build() -> View
}

protocol ViewControllerBuilder {
    func buildViewController() -> UIViewController
}
