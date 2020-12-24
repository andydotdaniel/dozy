//
//  URLSession.swift
//  Dozy
//
//  Created by Andrew Daniel on 6/21/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import Foundation

protocol URLSessionalDataTasking {
    func resume()
}

extension URLSessionTask: URLSessionalDataTasking {}

protocol URLSessionable {
    func createDataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionalDataTasking
    func createUploadTask(with request: URLRequest, from bodyData: Data?, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionalDataTasking
}

extension URLSession: URLSessionable {
    
    func createDataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionalDataTasking {
        dataTask(with: request, completionHandler: completionHandler)
    }
    
    func createUploadTask(with request: URLRequest, from bodyData: Data?, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionalDataTasking {
        uploadTask(with: request, from: bodyData, completionHandler: completionHandler)
    }
    
}
