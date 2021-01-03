//
//  Storage.swift
//  Dozy
//
//  Created by Andrew Daniel on 12/31/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import FirebaseStorage

protocol RemoteStorageReferencing {
    func uploadData(_ data: Data, metadata: [String: Any]?, completion: ((Error?) -> Void)?)
    func downloadURL(completion: @escaping (URL?, Error?) -> Void)
    func delete(completion: ((Error?) -> Void)?)
}

extension StorageReference: RemoteStorageReferencing {
    
    func uploadData(_ data: Data, metadata: [String: Any]?, completion: ((Error?) -> Void)?) {
        let metadata: StorageMetadata? = metadata.map { StorageMetadata(dictionary: $0) } ?? nil
        putData(data, metadata: metadata, completion: { _, error in
            completion?(error)
        })
    }
    
}

protocol RemoteStorageable {
    func reference(with pathString: String) -> RemoteStorageReferencing
}

extension Storage: RemoteStorageable {
    func reference(with pathString: String) -> RemoteStorageReferencing {
        self.reference(withPath: pathString)
    }
}
