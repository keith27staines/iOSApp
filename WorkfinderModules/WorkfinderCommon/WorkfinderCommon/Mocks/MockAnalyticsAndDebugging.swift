
import Foundation

public class MockF4SAnalyticsAndDebugging : F4SAnalyticsAndDebugging {

    var identities: [F4SUUID] = []
    var aliases: [F4SUUID] = []
    
    public func identity(userId: F4SUUID) {
        identities.append(userId)
    }
    
    public func alias(userId: F4SUUID) {
        aliases.append(userId)
    }
    
    var notifiedErrors = [Error]()
    
    public func notifyError(_ error: NSError, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        notifiedErrors.append(error)
    }
    
    var breadcrumbs = [String]()
    public func leaveBreadcrumb(with message: String, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        breadcrumbs.append(message)
    }
    
    var updateHistoryCallCount: Int = 0
    public func updateHistory() {
        updateHistoryCallCount += 1
    }
    
    var textCombiningHistoryAndSessionLogCallCount: Int = 0
    public func textCombiningHistoryAndSessionLog() -> String? {
        textCombiningHistoryAndSessionLogCallCount += 1
        return ""
    }
    
    var _userCanAccessDebugMenu: Bool = false
    public func userCanAccessDebugMenu() -> Bool {
        return _userCanAccessDebugMenu
    }
    
    var loggedErrorMessages = [String]()
    public func error(message: String, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        loggedErrorMessages.append(message)
    }
    
    var loggedErrors = [Error]()
    public func error(_ error: Error, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        loggedErrors.append(error)
    }
    
    var debugMessages = [String]()
    public func debug(_ message: String, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        debugMessages.append(message)
    }
}
