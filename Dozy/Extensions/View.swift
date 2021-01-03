//
//  View.swift
//  Dozy
//
//  Created by Andrew Daniel on 1/3/21.
//  Copyright © 2021 Andrew Daniel. All rights reserved.
//

import SwiftUI
import UIKit

extension View {
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
}
