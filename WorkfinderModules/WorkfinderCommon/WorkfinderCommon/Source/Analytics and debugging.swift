import Foundation

public protocol F4SAnalyticsAndDebugging : F4SAnalytics & F4SDebugging {}

public protocol F4SAnalytics {
    func identity(userId: F4SUUID)
    func alias(userId: F4SUUID)
}

public protocol F4SDebugging {
    func notifyError(_ error: Error)
    func leaveBreadcrumb(with message: String)
    func updateHistory()
    func textCombiningHistoryAndSessionLog() -> String?
    func userCanAccessDebugMenu() -> Bool
    func error(message: String)
    func error(_ error: Error)
    func debug(message: String)
}
