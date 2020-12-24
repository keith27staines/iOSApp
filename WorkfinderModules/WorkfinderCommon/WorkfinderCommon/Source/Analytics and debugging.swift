import Foundation

public protocol DeviceRegisteringProtocol {
    func registerDevice(token: Data)
}

public extension DeviceRegisteringProtocol {
    /// ueful for debugging/testing with push notification app
    func tokenToString(token: Data) -> String {
        return token.map { String(format: "%02x", $0) }.joined()
    }
}

public protocol F4SAnalyticsAndDebugging : class, F4SAnalytics & F4SDebugging {
    func updateIdentity()
}

public protocol F4SAnalytics {
    func track(_ event: TrackingEventType)
}

public protocol F4SDebugging {
    func leaveBreadcrumb(with message: String, functionName: StaticString, fileName: StaticString, lineNumber: Int)
    func error(message: String, functionName: StaticString, fileName: StaticString, lineNumber: Int)
    func error(_ error: Error, functionName: StaticString, fileName: StaticString, lineNumber: Int)
    func debug(_ message: String, functionName: StaticString, fileName: StaticString, lineNumber: Int)
    func notifyError(_ error: NSError, functionName: StaticString, fileName: StaticString, lineNumber: Int, callDetails: String)
}
