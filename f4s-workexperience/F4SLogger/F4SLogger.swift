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
    
    public init() {
        let environment = Config.environment
        let user = UserRepository().loadUser()
        let uuid = user.uuid ?? "unregistered"
        let name = user.fullname
        let email = user.email
        startBugsnag(for: environment, uuid: uuid, name: name, email: email)
        startMixpanel(for: environment, uuid: uuid, name: name, email: email)
        trackAppOpenedEvent()
    }
    
    func trackAppOpenedEvent() {
        let localStore = LocalStore()
        let isFirstLaunch = localStore.value(key: .isFirstLaunch) as? Bool ?? true
        let openEvent: TrackEvent
        openEvent = isFirstLaunch ? TrackEventFactory.makeFirstUse() : TrackEventFactory.makeAppOpen()
        self.track(event: openEvent)
    }
    
    func startMixpanel(for environment: EnvironmentType,
                       uuid: F4SUUID,
                       name: String?,
                       email: String?) {
        switch environment {
        case .production: Mixpanel.initialize(token: "611e14d8691f7e2dfbb7d5313b212b29")
        case .staging: Mixpanel.initialize(token: "611e14d8691f7e2dfbb7d5313b212b29")
        }
        mixPanel.identify(distinctId: uuid)
        guard let email = email else { return }
        mixPanel.people.set(properties: [ "$email": email])
    }
    
    func startBugsnag(for environment: EnvironmentType,
                      uuid: F4SUUID,
                      name: String?,
                      email: String?) {
        let bugsnagConfiguration = BugsnagConfiguration()
        switch environment {
        case .staging:
            bugsnagConfiguration.releaseStage = "staging"
            bugsnagConfiguration.apiKey = "e965364f05c37d903a6aa3f34498cc3f"

        case .production:
            bugsnagConfiguration.releaseStage = "production"
            bugsnagConfiguration.apiKey = "e965364f05c37d903a6aa3f34498cc3f"
        }
        bugsnagConfiguration.setUser(uuid, withName:name, andEmail:email)
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

