//
//  MockAnalyticsAndDebugging.swift
//  f4s-workexperienceTests
//
//  Created by Keith Dev on 21/02/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation
import WorkfinderCommon

@testable import f4s_workexperience

class MockF4SAnalyticsAndDebugging : F4SAnalyticsAndDebugging {
    
    var identities: [F4SUUID] = []
    var aliases: [F4SUUID] = []
    
    func identity(userId: F4SUUID) {
        identities.append(userId)
    }
    
    func alias(userId: F4SUUID) {
        aliases.append(userId)
    }
    
    var notifiedErrors = [Error]()
    
    func notifyError(_ error: Error) {
        notifiedErrors.append(error)
    }
    
    var breadcrumbs = [String]()
    func leaveBreadcrumb(with message: String) {
        breadcrumbs.append(message)
    }
    
    var updateHistoryCallCount: Int = 0
    func updateHistory() {
        updateHistoryCallCount += 1
    }
    
    var textCombiningHistoryAndSessionLogCallCount: Int = 0
    func textCombiningHistoryAndSessionLog() -> String? {
        textCombiningHistoryAndSessionLogCallCount += 1
        return ""
    }
    
    var _userCanAccessDebugMenu: Bool = false
    func userCanAccessDebugMenu() -> Bool {
        return _userCanAccessDebugMenu
    }
    
    var loggedErrorMessages = [String]()
    func error(message: String) {
        loggedErrorMessages.append(message)
    }
    
    var loggedErrors = [Error]()
    func error(_ error: Error) {
        loggedErrors.append(error)
    }
    
    var debugMessages = [String]()
    func debug(message: String) {
        debugMessages.append(message)
    }
}
