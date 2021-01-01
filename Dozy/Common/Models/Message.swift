//
//  Message.swift
//  Dozy
//
//  Created by Andrew Daniel on 7/19/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import UIKit

struct Message: Codable {
    let imageName: String?
    let imageUrl: String?
    let bodyText: String?
    let channel: Channel
}

extension Message {
    var uiImage: UIImage? {
        if let imageName = self.imageName, let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            return UIImage(contentsOfFile: documentsDirectory.appendingPathComponent(imageName).path)
        } else {
            return nil
        }
    }
}
