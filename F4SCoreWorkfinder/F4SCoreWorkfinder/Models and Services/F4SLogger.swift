//
//  F4SLogger.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 10/07/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation
import Analytics
import Segment_Bugsnag
import Bugsnag

public protocol F4SAnalyticsAndDebugging : F4SAnalytics & F4SDebugging {}

public protocol F4SAnalytics {
    func identity(userId: F4SUUID)
    func alias(userId: F4SUUID)
}

public protocol F4SDebugging {
    func notifyError(_ error: Error)
    func leaveBreadcrumb(with message: String)
    func updateHistory()
    func textCombiningHistoryAndSessionLog() -> String?
    func userCanAccessDebugMenu() -> Bool
}

public var f4sLog: F4SAnalyticsAndDebugging?

public var analytics: F4SAnalytics? {
    return f4sLog
}

public var debug: F4SDebugging? {
    return f4sLog
}

public class F4SLog : F4SAnalyticsAndDebugging {
    
    private var analytics: SEGAnalytics
    private var f4sDebug: F4SDebug?
    
    public init() {
        let segmentWriteKey: String
        switch Config.environment {
        case .staging:
            segmentWriteKey = "i6ZAvwf9RlqSzghak9Sg03MXyVeXo3kZ"
        case .production:
            segmentWriteKey = "G5DSK58YEvZDJx3KrnNAWvNg5xb5Uy51"
        }
        let config = SEGAnalyticsConfiguration(writeKey: segmentWriteKey)
        config.trackApplicationLifecycleEvents = true
        config.recordScreenViews = true
        if let bugsnagIntegrationFactory = SEGBugsnagIntegrationFactory.instance() {
            config.use(bugsnagIntegrationFactory)
        }
        SEGAnalytics.setup(with: config)
        analytics = SEGAnalytics.shared()
        
        do {
            f4sDebug = try F4SDebug()
        } catch (let error) {
            assertionFailure("Failed to initialize logger: \(error)")
        }
    }
}

extension F4SLog : F4SAnalytics {
    public func alias(userId: F4SUUID) {
        analytics.alias(userId)
    }
    
    public func identity(userId: F4SUUID) {
        analytics.identify(userId)
    }
}

extension F4SLog : F4SDebugging {
    public func notifyError(_ error: Error) {
        Bugsnag.notifyError(error)
    }
    
    public func leaveBreadcrumb(with message: String) {
        Bugsnag.leaveBreadcrumb(withMessage: message)
    }
    
    public func updateHistory() {
        f4sDebug?.updateHistory()
    }
    public func textCombiningHistoryAndSessionLog() -> String? {
        return f4sDebug?.textCombiningHistoryAndSessionLog()
    }
    
    public func userCanAccessDebugMenu() -> Bool {
        return f4sDebug?.userCanAccessDebugMenu() ?? false
    }
}

class F4SDebug {
    
    static let logDefaultDirectory : URL = FileHelper.getDocumentsURL()
    static let historyFileName: String = "workfinder_debug_history"
    static let loggerFileName: String = "logger_session"
    static let historyFileExtension: String = "log"
    static let loggerFileExtension: String = "log"
    
    let directory: URL
    
    var debugHistoryUrl: URL {
        return directory
            .appendingPathComponent(F4SDebug.historyFileName)
            .appendingPathExtension(F4SDebug.historyFileExtension)
    }
    
    var loggerUrl: URL {
        return directory
            .appendingPathComponent(F4SDebug.loggerFileName)
            .appendingPathExtension(F4SDebug.loggerFileExtension)
    }
    
    enum F4SDebugError : Error {
        case invalidDirectoryForLogfile
        case initializationError
    }
    
    init(directory: URL? = nil) throws {
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
    
    func updateHistory() {
        // Copy content of logger file to history file
        let text = textCombiningHistoryAndSessionLog()
        guard let fileHandle = FileHandle(forWritingAtPath: debugHistoryUrl.path) else {
            print("cannot open log file for writing")
            return
        }
        fileHandle.seekToEndOfFile()
        fileHandle.write(text.data(using: .utf8)!)
    }
    
    func textCombiningHistoryAndSessionLog() -> String {
        do {
            let history = try String(contentsOf: debugHistoryUrl)
            let logged =  try String(contentsOf: loggerUrl)
            return history + "\n\n\nBegin logger file\n\n" + logged
        } catch (let error) {
            return "Log unavailable \n\(error)"
        }
    }
    
    lazy var historyHeader: String = {
        return "History from: \(Date())"
    }()
    
    func userCanAccessDebugMenu() -> Bool {
        #if DEBUG
        return true
        #else
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
        #endif
        
    }
    
    private func setupLogfile() throws {
        let fileManager = FileManager.default
        try deleteHistoryFileIfExistsAndNotCreatedToday(fileManager: fileManager, logfile: debugHistoryUrl)
        createFileIfNotExists(fileManager: fileManager, url: debugHistoryUrl, initialContent: historyHeader)
    }
    
    private func deleteHistoryFileIfExistsAndNotCreatedToday(fileManager: FileManager, logfile: URL) throws {
        if fileManager.fileExists(atPath: logfile.path) {
            let attributes = try! fileManager.attributesOfItem(atPath: logfile.path)
            let createdDate: Date = (attributes[FileAttributeKey.creationDate] as! NSDate) as Date
            if !NSCalendar.current.isDateInToday(createdDate) {
                try fileManager.removeItem(at: logfile)
            }
        }
    }
    
    private func createFileIfNotExists(fileManager: FileManager, url: URL, initialContent: String? = nil) {
        if !fileManager.fileExists(atPath: url.path) {
            let data = initialContent?.data(using: .utf8)
            fileManager.createFile(atPath: url.path, contents: data, attributes: nil)
        }
    }
}

