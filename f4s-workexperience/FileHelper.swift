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

    static func deleteFileIfExists(path: String) -> Bool {
        guard fileExists(path: path) else { return true }
        do {
            try FileManager.default.removeItem(atPath: path)
            return true
        } catch {
            return false
        }
    }
    
    static func moveFile(fromUrl: URL, toUrl: URL) {
        guard fileExists(path: fromUrl.path) else { return }
        guard deleteFileIfExists(path: toUrl.path) else { return }
        do {
            try FileManager.default.moveItem(at: fromUrl, to: toUrl)
            _ = deleteFileIfExists(path: fromUrl.path)
        } catch {
            
        }
    }

    static func fileExists(path: String) -> Bool {
        return FileManager.default.fileExists(atPath: path)
    }

    static func saveData(data: NSData, path: URL) {
        data.write(toFile: path.path, atomically: true)
    }
}
