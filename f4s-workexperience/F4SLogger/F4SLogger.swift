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

public class F4SLog : F4SAnalyticsAndDebugging {
    
    public init() {
        let environmentType = Config.environment
        startBugsnag(environmentType: environmentType)
    }
    
    func startBugsnag(environmentType: EnvironmentType) {
        let bugsnagConfiguration = BugsnagConfiguration()
        switch environmentType {
        case .staging:
            bugsnagConfiguration.releaseStage = "staging"
            bugsnagConfiguration.apiKey = "e965364f05c37d903a6aa3f34498cc3f"

        case .production:
            bugsnagConfiguration.releaseStage = "production"
            bugsnagConfiguration.apiKey = "e965364f05c37d903a6aa3f34498cc3f"
        }
        let user = UserRepository().loadUser()
        bugsnagConfiguration.setUser(user.uuid ?? "unregistered user", withName:user.nickname, andEmail:user.email)
        Bugsnag.start(with: bugsnagConfiguration)
    }
}

extension F4SLog : F4SAnalytics {
    
    public func track(event: TrackEvent, properties: [String : Any]?) {

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
//        let parameters = [
//            "name": screen,
//            "previous_screen": previous
//        ]
//        Analytics.logEvent("SCREEN", parameters: parameters)
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
}

