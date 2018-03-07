//
//  F4SDebugModel.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 06/03/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation

public class F4SDebug {
    
    public static let logDefaultDirectory : URL = FileHelper.getDocumentsURL()
    public static let historyFileName: String = "workfinder_debug_history"
    public static let loggerFileName: String = "logger_session"
    public static let historyFileExtension: String = "log"
    public static let loggerFileExtension: String = "log"
    public static var shared: F4SDebug? = nil

    
    public let directory: URL
    
    public var debugHistoryUrl: URL {
        return directory
            .appendingPathComponent(F4SDebug.historyFileName)
            .appendingPathExtension(F4SDebug.historyFileExtension)
    }
    
    public var loggerUrl: URL {
        return directory
            .appendingPathComponent(F4SDebug.loggerFileName)
            .appendingPathExtension(F4SDebug.loggerFileExtension)
    }
    
    public enum F4SDebugError : Error {
        case invalidDirectoryForLogfile
        case initializationError
    }
    
    public init(directory: URL? = nil) throws {
        let directory = directory ?? F4SDebug.logDefaultDirectory
        guard directory.hasDirectoryPath else {
            log.setup(level: .debug, showThreadName: true, showLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: nil, fileLevel: .debug)
            throw F4SDebugError.invalidDirectoryForLogfile
        }
        self.directory = directory
        do {
            try setupLogfile()
            log.setup(level: .debug, showThreadName: true, showLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: loggerUrl.path, fileLevel: .debug)
        } catch (let error) {
            log.setup(level: .debug, showThreadName: true, showLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: nil, fileLevel: .debug)
            throw error
        }
    }
    
    public func updateHistory() {
        // Copy content of logger file to history file
        let text = textCombiningHistoryAndSessionLog()
        guard let fileHandle = FileHandle(forWritingAtPath: debugHistoryUrl.path) else {
            print("cannot open log file for writing")
            return
        }
        fileHandle.seekToEndOfFile()
        fileHandle.write(text.data(using: .utf8)!)
    }
    
    public func textCombiningHistoryAndSessionLog() -> String {
        do {
            let history = try String(contentsOf: debugHistoryUrl)
            let logged =  try String(contentsOf: loggerUrl)
            return history + "\n\n\nBegin logger file\n\n" + logged
        } catch (let error) {
            return "Log unavailable \n\(error)"
        }
    }
    
    public lazy var historyHeader: String = {
        return "History from: \(Date())"
    }()
    
    public func userCanAccessDebugMenu() -> Bool {
        if Config.ENVIRONMENT == "STAGING" {
            return true
        }
        guard let lowercasedEmail = UserInfoDBOperations.sharedInstance.getUserInfo()?.email.lowercased() else {
            return false
        }
        guard lowercasedEmail.contains("founders4schools.org.uk") ||
              lowercasedEmail.contains("workfinder.com") else {
            return false
        }
        return true
    }
    
    func setupLogfile() throws {
        let fileManager = FileManager.default
        try deleteHistoryFileIfExistsAndNotCreatedToday(fileManager: fileManager, logfile: debugHistoryUrl)
        createFileIfNotExists(fileManager: fileManager, url: debugHistoryUrl, initialContent: historyHeader)
    }
    
    func deleteHistoryFileIfExistsAndNotCreatedToday(fileManager: FileManager, logfile: URL) throws {
        if fileManager.fileExists(atPath: logfile.path) {
            let attributes = try! fileManager.attributesOfItem(atPath: logfile.path)
            let createdDate: Date = (attributes[FileAttributeKey.creationDate] as! NSDate) as Date
            if !NSCalendar.current.isDateInToday(createdDate) {
                try fileManager.removeItem(at: logfile)
            }
        }
    }
    
    func createFileIfNotExists(fileManager: FileManager, url: URL, initialContent: String? = nil) {
        if !fileManager.fileExists(atPath: url.path) {
            let data = initialContent?.data(using: .utf8)
            fileManager.createFile(atPath: url.path, contents: data, attributes: nil)
        }
    }
}
