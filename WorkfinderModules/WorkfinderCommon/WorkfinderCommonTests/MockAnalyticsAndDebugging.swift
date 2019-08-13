import WorkfinderCommon

class MockF4SAnalyticsAndDebugging : F4SAnalyticsAndDebugging {
    
    var identities: [F4SUUID] = []
    var aliases: [F4SUUID] = []
    var breadcrumbs = [String]()
    var updateHistoryCallCount: Int = 0
    var textCombiningHistoryAndSessionLogCallCount: Int = 0
    var _userCanAccessDebugMenu: Bool = false
    var loggedErrorMessages = [String]()
    var loggedErrors = [Error]()
    var debugMessages = [String]()
    var notifiedErrors = [Error]()
    
    func identity(userId: F4SUUID) {
        identities.append(userId)
    }
    
    func alias(userId: F4SUUID) {
        aliases.append(userId)
    }
    
    func notifyError(_ error: Error, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        notifiedErrors.append(error)
    }
    
    func notifyError(_ error: NSError, functionName: StaticString, fileName: StaticString, lineNumber: Int) {
        notifiedErrors.append(error)
    }
    
    
    func leaveBreadcrumb(with message: String, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        breadcrumbs.append(message)
    }
    
    func updateHistory() {
        updateHistoryCallCount += 1
    }
    
    func textCombiningHistoryAndSessionLog() -> String? {
        textCombiningHistoryAndSessionLogCallCount += 1
        return ""
    }
    
    func userCanAccessDebugMenu() -> Bool {
        return _userCanAccessDebugMenu
    }
    
    func error(message: String, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        loggedErrorMessages.append(message)
    }
    
    func error(_ error: Error, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        loggedErrors.append(error)
    }
    
    func debug(_ message: String, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        debugMessages.append(message)
    }
}
