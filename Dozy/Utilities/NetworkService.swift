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
        case .get:
            getRequest(request, completion: completion)
        }
    }
    
    private func postRequest<T: Decodable>(_ request: NetworkRequest, completion: @escaping (Result<T, NetworkService.RequestError>) -> Void) {
        var urlRequest = URLRequest(url: request.url)
        urlRequest.httpMethod = "POST"
        urlRequest.allHTTPHeaderFields = getHeaders(with: request)
        
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
    
    private func getRequest<T: Decodable>(_ request: NetworkRequest, completion: @escaping (Result<T, NetworkService.RequestError>) -> Void) {
        var urlComponents = URLComponents(url: request.url, resolvingAgainstBaseURL: false)
        urlComponents?.queryItems = request.parameters.map {
            URLQueryItem(name: $0.key, value: String(describing: $0.value))
        }
        
        let formattedPercentEncodedQuery = urlComponents?.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        urlComponents?.percentEncodedQuery = formattedPercentEncodedQuery
        
        guard let url = urlComponents?.url else {
            completion(.failure(.unknown(message: "URL could not be generated for request")))
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.allHTTPHeaderFields = getHeaders(with: request)
        request.headers.forEach { header in
            urlRequest.allHTTPHeaderFields?[header.key] = header.value
        }
        
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
    
    private func getHeaders(with request: NetworkRequest) -> [String: String] {
        var headers: [String: String] = [
            "Content-Type": request.contentType.rawValue
        ]
        
        request.headers.forEach { header in
            headers[header.key] = header.value
        }
        
        return headers
    }
    
}
