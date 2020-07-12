//
//  JSONLoader.swift
//  DozyTests
//
//  Created by Andrew Daniel on 7/12/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import Foundation

class JSONLoader {
    
    enum FileError: Error {
        case fileNotFound
    }
    
    class func load(fileName: String) throws -> URLSessionMockResult {
        if let path = TestBundle.bundle.path(forResource: fileName, ofType: "json") {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            return URLSessionMockResult(data: data, urlResponse: nil, error: nil)
        } else {
            throw FileError.fileNotFound
        }
    }
    
}
