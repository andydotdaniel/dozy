//
//  Configuration.swift
//  Dozy
//
//  Created by Andrew Daniel on 6/14/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import Foundation

struct Configuration: Codable {
    
    let clientId: String
    let clientSecret: String
    
    private enum CodingKeys: String, CodingKey {
        case clientId = "SLACK_CLIENT_ID"
        case clientSecret = "SLACK_CLIENT_SECRET"
    }
    
    static func create() -> Configuration {
        guard let url = Bundle.main.url(forResource: "Configuration", withExtension: "plist") else {
            preconditionFailure("Failed to load configuration file")
        }
            
        do {
            let data = try Data(contentsOf: url)
            return try PropertyListDecoder().decode(Configuration.self, from: data)
        } catch {
            preconditionFailure("Failed to create app configuration")
        }
    }
    
}

