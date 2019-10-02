import Foundation

public protocol F4SAnalyticsAndDebugging : F4SAnalytics & F4SDebugging {}

public protocol F4SAnalytics {
    func identity(userId: F4SUUID)
    func alias(userId: F4SUUID)
    func track(event: String)
    func track(event: String, properties: [String : Any])
    func track(event: String, properties: [String : Any], options: [String : Any])
    func screen(title: String)
    func screen(title: String, properties: [String : Any])
    func screen(title: String, properties: [String : Any], options: [String : Any])
}

public protocol F4SDebugging {
    func notifyError(_ error: NSError, functionName: StaticString, fileName: StaticString, lineNumber: Int)
    func leaveBreadcrumb(with message: String, functionName: StaticString, fileName: StaticString, lineNumber: Int)
    func updateHistory()
    func textCombiningHistoryAndSessionLog() -> String?
    func userCanAccessDebugMenu() -> Bool
    func error(message: String, functionName: StaticString, fileName: StaticString, lineNumber: Int)
    func error(_ error: Error, functionName: StaticString, fileName: StaticString, lineNumber: Int)
    func debug(_ message: String, functionName: StaticString, fileName: StaticString, lineNumber: Int)
}
