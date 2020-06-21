//
//  NetworkService.swift
//  Dozy
//
//  Created by Andrew Daniel on 6/15/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import Foundation

protocol NetworkRequesting {
    func peformNetworkRequest<T: Decodable>(_ request: NetworkRequest, completion: @escaping (Result<T, NetworkService.RequestError>) -> Void)
}

struct NetworkService: NetworkRequesting {
    
    enum RequestError: Error {
        case unknown(message: String)
        case decodableParsingFailed
    }
    
    private let urlSession: URLSessionable
    
    init(urlSession: URLSessionable = URLSession.shared) {
        self.urlSession = urlSession
    }
    
    func peformNetworkRequest<T: Decodable>(_ request: NetworkRequest, completion: @escaping (Result<T, NetworkService.RequestError>) -> Void) {
        switch request.httpMethod {
        case .post:
            postRequest(request, completion: completion)
        }
    }
    
    private func postRequest<T: Decodable>(_ request: NetworkRequest, completion: @escaping (Result<T, NetworkService.RequestError>) -> Void) {
        var urlRequest = URLRequest(url: request.url)
        urlRequest.httpMethod = "POST"
        urlRequest.allHTTPHeaderFields = [
            "Content-Type": request.contentType.rawValue
        ]
        
        let httpBody: Data? = {
            switch request.contentType {
            case .json:
                return try? JSONSerialization.data(withJSONObject: request.parameters, options: .prettyPrinted)
            case .urlEncodedForm:
                let encodedString = request.parameters.reduce("") { "\($0)\($1.0)=\($1.1)&" }
                return encodedString.data(using: .utf8, allowLossyConversion: false)
            }
        }()
        urlRequest.httpBody = httpBody
        
        urlSession.createDataTask(with: urlRequest, completionHandler: { data, _, error in
            if let error = error {
                completion(.failure(.unknown(message: error.localizedDescription)))
                return
            }
            
            guard let data = data, let decodedObject = try? JSONDecoder().decode(T.self, from: data) else {
                completion(.failure(.decodableParsingFailed))
                return
            }
            
            completion(.success(decodedObject))
        }).resume()
        
    }
    
}