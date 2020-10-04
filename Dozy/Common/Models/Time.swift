//
//  Time.swift
//  Dozy
//
//  Created by Andrew Daniel on 10/4/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import Foundation

struct Time {
    
    let hour: Int
    let minute: Int
    
    init(from date: Date) {
        let calendar = Calendar.current
        
        self.hour = calendar.component(.hour, from: date)
        self.minute = calendar.component(.minute, from: date)
    }
    
    init(hour: Int, minute: Int) {
        self.hour = hour
        self.minute = minute
    }
    
}
