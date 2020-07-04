//
//  KeyboardListener.swift
//  Dozy
//
//  Created by Andrew Daniel on 7/4/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import UIKit
import Foundation

class KeyboardListener: ObservableObject {
    
    @Published var keyboardHeight: CGFloat = 0
    
    init() {
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardDidShowNotification,
            object: nil,
            queue: .main
        ) { notification in
            guard let userInfo = notification.userInfo,
                let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
                                                
            self.keyboardHeight = keyboardFrame.height
        }
        
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardDidHideNotification,
            object: nil,
            queue: .main
        ) { notification in
            self.keyboardHeight = 0
        }
    }
    
}
