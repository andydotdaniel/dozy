//
//  NetworkRequest.swift
//  Dozy
//
//  Created by Andrew Daniel on 6/15/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import Foundation

struct NetworkRequest {
    
    enum ContentType: String {
        case json = "application/json"
        case urlEncodedForm = "application/x-www-form-urlencoded"
    }
    
    enum HTTPMethod {
        case post
    }
    
    let url: URL
    let httpMethod: HTTPMethod
    let parameters: [String: Any]
    let contentType: ContentType
    
    init?(url urlString: String, httpMethod: HTTPMethod, parameters: [String: Any] = [:], contentType: ContentType = .json) {
        guard let url = URL(string: urlString) else { return nil }
        
        self.url = url
        self.httpMethod = httpMethod
        self.parameters = parameters
        self.contentType = contentType
    }
    
}
