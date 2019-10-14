//
//  F4SLogger.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 10/07/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation
import XCGLogger
import Bugsnag
import WorkfinderCommon
import Firebase

public class F4SLog : F4SAnalyticsAndDebugging {
    
    private var f4sDebug: F4SDebug?
    
    public init() {
        let environmentType = Config.environment
        startBugsnag(environmentType: environmentType)
        startFirebase(environmentType: environmentType)
        do {
            f4sDebug = try F4SDebug()
        } catch (let error) {
            assertionFailure("Failed to initialize logger: \(error)")
        }
    }
    
    func startBugsnag(environmentType: EnvironmentType) {
        let bugsnagConfiguration = BugsnagConfiguration()
        switch environmentType {
        case .staging:
            bugsnagConfiguration.releaseStage = "staging"
            bugsnagConfiguration.apiKey = "3e5b13ff2914e5593874d37282c5f40a"

        case .production:
            bugsnagConfiguration.releaseStage = "production"
            bugsnagConfiguration.apiKey = "1b2c62d35dbf70232d3b4d4c5aca5ebe"
        }
        let userUuid = F4SUser().uuid ?? "first_use_temp_\(UUID().uuidString)"
        bugsnagConfiguration.setUser(userUuid, withName:"", andEmail:"")
        Bugsnag.start(with: bugsnagConfiguration)
    }
    
    func startFirebase(environmentType: EnvironmentType) {
        let plistName: String?
        switch environmentType {
        case .staging: plistName = "firebase_staging"
        case .production: plistName = "firebase_live"
        }
        guard
            let plist = plistName,
            let path = Bundle.main.path(forResource: plist, ofType: "plist"),
            let firebaseOptions = FirebaseOptions(contentsOfFile: path) else { return }
        FirebaseApp.configure(options: firebaseOptions)
        Analytics.setAnalyticsCollectionEnabled(true)
    }
}

extension F4SLog : F4SAnalytics {
    public func track(event: String) {
        track(event: event, properties: [:])
    }
    
    public func track(event: String, properties: [String : Any]) {
        track(event: event, properties: properties, options: [:])
    }
    
    public func track(event: String, properties: [String : Any], options: [String : Any]) {
        Analytics.logEvent(event, parameters: properties)
    }
    
    public func screen(_ name: ScreenName) {
        writeScreenToAnalytics(name)
    }
    
    public func screen(_ name: ScreenName, originScreen origin: ScreenName) {
        writeScreenToAnalytics(name, originScreen: origin)
    }
    
    func writeScreenToAnalytics(_ name: ScreenName, originScreen origin: ScreenName = .notSpecified) {
        let screen = name.rawValue.replacingOccurrences(of: " ", with: "_")
        let previous = origin.rawValue.replacingOccurrences(of: " ", with: "_")
        let parameters = [
            "name": screen,
            "previous_screen": previous
        ]
        Analytics.logEvent("SCREEN", parameters: parameters)
        print("SCREEN DID APPEAR: \(screen) from \(previous)")
    }
    
    public func identity(userId: F4SUUID) {

    }
    
    public func alias(userId: F4SUUID) {

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

