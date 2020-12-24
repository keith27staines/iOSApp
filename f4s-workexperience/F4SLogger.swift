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
import Mixpanel
import WorkfinderCommon
import UIKit

public class F4SLog {

    var mixPanel: MixpanelInstance { return Mixpanel.mainInstance() }
    
    public func updateIdentity() {
        let user = UserRepository().loadUser()
        guard let userId = user.uuid else { return }
        if let email = user.email {
            mixPanel.people.set(properties: ["$email": email])
        }
        mixPanel.identify(distinctId: userId)
    }
    
    public init() {
        let environment = Config.environment
        startBugsnag(for: environment)
        startMixpanel(for: environment)
        updateIdentity()
    }
    
    func startMixpanel(for environment: EnvironmentType) {
        switch environment {
        case .production: Mixpanel.initialize(token: "611e14d8691f7e2dfbb7d5313b212b29")
        case .staging: Mixpanel.initialize(token: "cbba1c1eba2a6ad2bef0356f19396cd0")
        case .develop: Mixpanel.initialize(token: "416fe88ddb1b0375acaf5cb6c1d998ec")
        }
    }
    
    func startBugsnag(for environment: EnvironmentType) {
        let bugsnagConfiguration: BugsnagConfiguration
        switch environment {
        case .develop:
            bugsnagConfiguration = BugsnagConfiguration("e965364f05c37d903a6aa3f34498cc3f")
            bugsnagConfiguration.releaseStage = "develop"
            assert(bugsnagConfiguration.apiKey == "e965364f05c37d903a6aa3f34498cc3f", "Wrong api key")
        case .staging:
            bugsnagConfiguration = BugsnagConfiguration("e965364f05c37d903a6aa3f34498cc3f")
            bugsnagConfiguration.releaseStage = "staging"
            assert(bugsnagConfiguration.apiKey == "e965364f05c37d903a6aa3f34498cc3f", "Wrong api key")
            
        case .production:
            bugsnagConfiguration = BugsnagConfiguration("e965364f05c37d903a6aa3f34498cc3f")
            bugsnagConfiguration.releaseStage = "production"
            assert(bugsnagConfiguration.apiKey == "e965364f05c37d903a6aa3f34498cc3f", "Wrong api key")
        }
        let user = UserRepository().loadUser()
        bugsnagConfiguration.setUser(user.uuid, withEmail: user.email, andName: user.fullname)
        Bugsnag.start(with: bugsnagConfiguration)
    }
}

extension F4SLog : F4SAnalytics {
    
    public func track(_ eventType: TrackingEventType) {
        let event = TrackingEvent(type: eventType)
        let mixpanelProperties = event.additionalProperties.compactMapValues({ (value) -> MixpanelType? in
            value as? MixpanelType
        })
        assert(mixpanelProperties.count == event.additionalProperties.count)
        print(eventType)
        mixPanel.track(event: eventType.name, properties: mixpanelProperties)
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
    
    public func notifyError(_ error: NSError, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, callDetails: String = "No detail provided") {
        Bugsnag.notifyError(error) { (event) -> Bool in
            event.addMetadata(["callDetails":callDetails], section: "Call Details")
            return true
        }
    }
    
    public func leaveBreadcrumb(with message: String, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        XCGLogger.default.debug(message)
        Bugsnag.leaveBreadcrumb(withMessage: message)
    }
}

extension F4SLog: F4SAnalyticsAndDebugging {}

