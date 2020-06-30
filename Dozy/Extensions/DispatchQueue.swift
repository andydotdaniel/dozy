//
//  DispatchQueue.swift
//  Dozy
//
//  Created by Andrew Daniel on 6/30/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import Foundation

protocol DispatchQueueable {
    func async(block: @escaping () -> Void)
}

extension DispatchQueue: DispatchQueueable {
    func async(block: @escaping () -> Void) {
        self.async(execute: block)
    }
}
