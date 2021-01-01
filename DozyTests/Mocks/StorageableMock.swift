//
//  RemoteStorageableMock.swift
//  DozyTests
//
//  Created by Andrew Daniel on 12/31/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import Foundation
@testable import Dozy

class RemoteStorageReferencingMock: RemoteStorageReferencing {
    
    enum StorageReferenceError: Error {
        case someError
    }
    
    var error: Error?
    
    func uploadData(_ data: Data, metadata: [String : Any]?, completion: ((Error?) -> Void)?) {
        completion?(error)
    }
    
    let downloadURLString: String = "SOME_DOWNLOAD_URL_STRING"
    func downloadURL(completion: @escaping (URL?, Error?) -> Void) {
        completion(URL(string: downloadURLString), error)
    }
    
}

class RemoteStorageableMock: RemoteStorageable {
    
    let referenceMock: RemoteStorageReferencingMock = RemoteStorageReferencingMock()
    var pathStringCalled: String?
    func reference(with pathString: String) -> RemoteStorageReferencing {
        pathStringCalled = pathString
        return referenceMock
    }
    
}
