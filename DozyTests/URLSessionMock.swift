//
//  URLSessionMock.swift
//  DozyTests
//
//  Created by Andrew Daniel on 6/21/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import Foundation
@testable import Dozy

class URLSessionDataTaskMock: URLSessionalDataTasking {
    func resume() {}
}

struct URLSessionMockResult {
    let data: Data?
    let urlResponse: URLResponse?
    let error: Error?
}

class URLSessionMock: URLSessionable {
    
    var result: URLSessionMockResult?
    
    func createDataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionalDataTasking {
        guard let result = self.result else {
            preconditionFailure("URL session data task mocked result has not been set")
        }
        
        completionHandler(result.data, result.urlResponse, result.error)
        return URLSessionDataTaskMock()
    }
    
}
