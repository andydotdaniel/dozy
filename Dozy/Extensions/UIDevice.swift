//
//  UIDevice.swift
//  Dozy
//
//  Created by Andrew Daniel on 6/23/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import UIKit

extension UIDevice {
    
    enum ScreenType {
        case large
        case small
    }
    
    var screenType: ScreenType {
        if UIScreen.main.bounds.height <= 667 {
            return .small
        }
        
        return .large
    }
    
}
