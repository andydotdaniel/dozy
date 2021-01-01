//
//  FileManager.swift
//  Dozy
//
//  Created by Andrew Daniel on 1/1/21.
//  Copyright © 2021 Andrew Daniel. All rights reserved.
//

import Foundation

protocol FileManaging {
    func urls(for directory: FileManager.SearchPathDirectory, in domainMask: FileManager.SearchPathDomainMask) -> [URL]
    func removeItem(atPath path: String) throws
    func createFile(atPath path: String, contents data: Data?, attributes attr: [FileAttributeKey : Any]?) -> Bool
    func fileExists(atPath path: String) -> Bool
}

extension FileManager: FileManaging {}
