//
//  F4SLogger.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 10/07/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation
import XCGLogger
import WorkfinderCommon

public class F4SLog : F4SAnalyticsAndDebugging {
    
    private var analytics: SEGAnalytics
    private var f4sDebug: F4SDebug?
    
    public init() {

        switch Config.environment {
        case .staging:
   
        case .production:

        }
        
        do {
            f4sDebug = try F4SDebug()
        } catch (let error) {
            assertionFailure("Failed to initialize logger: \(error)")
        }
    }
}

extension F4SLog : F4SAnalytics {
    public func track(event: String) {
        analytics.track(event)
    }
    
    public func track(event: String, properties: [String : Any]) {
        analytics.track(event, properties: properties)
    }
    
    public func track(event: String, properties: [String : Any], options: [String : Any]) {
        analytics.track(event, properties: properties, options: options)
    }
    
    public func screen(_ name: ScreenName) {
        writeScreenToAnalytics(name)
    }
    
    public func screen(_ name: ScreenName, originScreen origin: ScreenName) {
        writeScreenToAnalytics(name, originScreen: origin)
    }
    
    func writeScreenToAnalytics(_ name: ScreenName, originScreen origin: ScreenName = .notSpecified) {
        analytics.screen(name.rawValue, properties: ["origin": origin.rawValue])
        print("SCREEN DID APPEAR: \(name.rawValue) from \(origin.rawValue)")
    }
    
    public func identity(userId: F4SUUID) {
        analytics.identify(userId)
    }
    
    public func alias(userId: F4SUUID) {
        analytics.alias(userId)
    }
}

extension F4SLog : F4SDebugging {
    public func error(message: String, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        XCGLogger.default.error(message, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
    }
    
    public func error(_ error: Error, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        XCGLogger.default.error(error, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
    }
    
    public func debug(_ message: String, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        XCGLogger.default.debug(message, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
    }
    
    public func notifyError(_ error: NSError, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        Bugsnag.notifyError(error) { report in
            report.depth += 2
            report.addMetadata(error.userInfo, toTabWithName: "UserInfo")
        }
    }
    
    public func leaveBreadcrumb(with message: String, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        XCGLogger.default.debug(message)
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
            throw F4SDebugError.invalidDirectoryForLogfile
        }
        self.directory = directory
        do {
            try setupLogfile()
            XCGLogger.default.setup(level: .debug, showThreadName: true, showLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: loggerUrl.path, fileLevel: .debug)
        } catch (let error) {
            XCGLogger.default.setup(level: .debug, showThreadName: true, showLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: nil, fileLevel: .debug)
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
        return false
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

