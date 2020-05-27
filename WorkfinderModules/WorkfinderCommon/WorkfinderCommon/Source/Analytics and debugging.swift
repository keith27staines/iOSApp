import Foundation

public protocol F4SAnalyticsAndDebugging : class, F4SAnalytics & F4SDebugging {}

public protocol F4SAnalytics {
    func identity(userId: F4SUUID)
    func alias(userId: F4SUUID)
    func track(event: TrackEvent, properties: [String: Any]?)
    func screen(_ name: ScreenName)
    func screen(_ name: ScreenName, originScreen: ScreenName)
}

public protocol F4SDebugging {
    func notifyError(_ error: NSError, functionName: StaticString, fileName: StaticString, lineNumber: Int)
    func leaveBreadcrumb(with message: String, functionName: StaticString, fileName: StaticString, lineNumber: Int)
    func error(message: String, functionName: StaticString, fileName: StaticString, lineNumber: Int)
    func error(_ error: Error, functionName: StaticString, fileName: StaticString, lineNumber: Int)
    func debug(_ message: String, functionName: StaticString, fileName: StaticString, lineNumber: Int)
}
