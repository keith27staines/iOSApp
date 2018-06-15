//
//  FileHelper.swift
//  f4s-workexperience
//
//  Created by Timea Tivadar on 11/17/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import Foundation
import UIKit

class FileHelper {
    static func getDocumentsURL() -> URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsURL
    }

    static func fileInDocumentsDirectory(filename: String) -> String {
        let fileURL = getDocumentsURL().appendingPathComponent(filename)
        return fileURL.path
    }

    static func fileInDocumentsDirectory(filename: String) -> URL {
        let fileURL = getDocumentsURL().appendingPathComponent(filename)
        return fileURL
    }

    static func deleteFile(path: String) {
        do {
            if FileHelper.fileExists(path: path) {
                try! FileManager.default.removeItem(atPath: path)
            }
        }
    }
    
    static func moveFile(fromUrl: URL, toUrl: URL) {
        deleteFile(path: toUrl.path)
        try! FileManager.default.moveItem(at: fromUrl, to: toUrl)
        deleteFile(path: fromUrl.path)
    }

    static func fileExists(path: String) -> Bool {
        if FileManager.default.fileExists(atPath: path) {
            return true
        }
        return false
    }

    static func saveData(data: NSData, path: URL) {
        data.write(toFile: path.path, atomically: true)
    }
}
