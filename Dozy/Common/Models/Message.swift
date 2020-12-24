//
//  Message.swift
//  Dozy
//
//  Created by Andrew Daniel on 7/19/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import UIKit

struct Message: Codable {
    let image: Data?
    let imageUrl: String?
    let bodyText: String?
    let channel: Channel
}
