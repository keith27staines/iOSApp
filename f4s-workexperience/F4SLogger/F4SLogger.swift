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

public class F4SLog : F4SAnalyticsAndDebugging {

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
        trackAppOpenedEvent()
    }
    
    func trackAppOpenedEvent() {
        let localStore = LocalStore()
        let isFirstLaunch = localStore.value(key: .isFirstLaunch) as? Bool ?? true
        let openEvent: TrackEvent
        openEvent = isFirstLaunch ? TrackEventFactory.makeFirstUse() : TrackEventFactory.makeAppOpen()
        self.track(event: openEvent)
    }
    
    func startMixpanel(for environment: EnvironmentType) {
        switch environment {
        case .production: Mixpanel.initialize(token: "611e14d8691f7e2dfbb7d5313b212b29")
        case .staging: Mixpanel.initialize(token: "416fe88ddb1b0375acaf5cb6c1d998ec")
        }
    }
    
    func startBugsnag(for environment: EnvironmentType) {
        let bugsnagConfiguration = BugsnagConfiguration()
        switch environment {
        case .staging:
            bugsnagConfiguration.releaseStage = "staging"
            bugsnagConfiguration.apiKey = "e965364f05c37d903a6aa3f34498cc3f"

        case .production:
            bugsnagConfiguration.releaseStage = "production"
            bugsnagConfiguration.apiKey = "e965364f05c37d903a6aa3f34498cc3f"
        }
        let user = UserRepository().loadUser()
        bugsnagConfiguration.setUser(user.uuid, withName:user.fullname, andEmail:user.email)
        Bugsnag.start(with: bugsnagConfiguration)
    }
}

extension F4SLog : F4SAnalytics {
    
    public func track(event: TrackEvent) {
        var mixpanelProperties = event.additionalProperties?.compactMapValues({ (value) -> MixpanelType? in
            value as? MixpanelType
        }) ?? [:]

        if let userUuid = UserRepository().loadUser().uuid {
            mixpanelProperties["with_user_id"] = userUuid
        }
        if let vendorUuid = UIDevice.current.identifierForVendor?.uuidString {
            mixpanelProperties["device_id"] = vendorUuid
        }
        mixPanel.track(event: event.name, properties: mixpanelProperties)
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
        Bugsnag.notifyError(error) { report in
            report.depth += 2
            report.addMetadata(["callDetails":callDetails], toTabWithName: "Call Details")
        }
    }
    
    public func leaveBreadcrumb(with message: String, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        XCGLogger.default.debug(message)
        Bugsnag.leaveBreadcrumb(withMessage: message)
    }
}

