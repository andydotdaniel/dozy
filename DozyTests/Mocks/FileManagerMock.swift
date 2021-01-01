//
//  FileManagerMock.swift
//  DozyTests
//
//  Created by Andrew Daniel on 1/1/21.
//  Copyright © 2021 Andrew Daniel. All rights reserved.
//

@testable import Dozy
import Foundation

class FileManagerMock: FileManaging {
    
    let documentsDirectoryURL = URL(string: "SOME_DIRECTORY")!
    func urls(for directory: FileManager.SearchPathDirectory, in domainMask: FileManager.SearchPathDomainMask) -> [URL] {
        if directory == .documentDirectory || domainMask == .userDomainMask {
            return [documentsDirectoryURL]
        }
        
        return []
    }
    
    var itemRemovedAtPath: String?
    func removeItem(atPath path: String) throws {
        itemRemovedAtPath = path
    }
    
    var fileCreatedAtPath: String?
    func createFile(atPath path: String, contents data: Data?, attributes attr: [FileAttributeKey : Any]?) -> Bool {
        fileCreatedAtPath = path
        return true
    }
    
    func fileExists(atPath path: String) -> Bool {
        return true
    }
    
}
