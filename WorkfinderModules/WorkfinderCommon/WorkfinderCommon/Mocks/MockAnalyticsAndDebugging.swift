
import Foundation

public class MockNetworkCallLogger: NetworkCallLoggerProtocol {
    
    public func logDeserializationError<T>(to type: T.Type, from data: Data, error: NSError) where T : Decodable {
        
    }
    
    public var attempting: String?
    public var logDataTaskFailureWasCalled: Bool = false
    public var logDataTaskSuccessWasCalled: Bool = false
    public var request: URLRequest?
    public var response: URLResponse?
    public var responseData: Data?
    public var error: Error?
    
    public func logDataTaskFailure(error: WorkfinderError) {
        logDataTaskFailureWasCalled = true
        self.attempting = error.attempting
        self.error = error
        self.request = error.urlRequest
        self.response = error.httpResponse
        self.responseData = error.responseData
    }
    
    public func logDataTaskSuccess(request: URLRequest, response: HTTPURLResponse, responseData: Data) {
        logDataTaskSuccessWasCalled = true
        self.request = request
        self.response = response
        self.responseData = responseData
    }
    
    public init() {}
}


public class MockF4SAnalyticsAndDebugging : F4SAnalyticsAndDebugging {
    
    public init() {}
    
    public struct AnalyticsItem {
        enum ItemType {
            case screen
            case track
        }
        var type: ItemType
        var name: String
        var properties: [String : Any]?
        var options: [String :  Any]?
    }
    
    public var analyticsItems = [AnalyticsItem]()
    public var identities: [F4SUUID] = []
    
    public func updateIdentity() {
        identities.append(UUID().uuidString)
    }
    
    public var aliases: [F4SUUID] = []

    public func alias(userId: F4SUUID) {
        aliases.append(userId)
    }

    public func track(_ event: TrackingEvent) {
        let notNilProperties = event.additionalProperties ?? [:]
        analyticsItems.append(AnalyticsItem(type: .track, name: event.name, properties: notNilProperties))
    }
    
    public func screen(_ name: ScreenName) {
        analyticsItems.append(AnalyticsItem(type: .screen, name: name.rawValue))
    }
    
    public func screen(_ name: ScreenName, originScreen: ScreenName) {
        let item = AnalyticsItem(
            type: .screen,
            name: name.rawValue,
            properties: ["origin" : originScreen.rawValue])
        analyticsItems.append(item)
    }
    
    public func screen(title: String, properties: [String : Any]) {
        analyticsItems.append(AnalyticsItem(type: .screen, name: title, properties: properties))
    }
    
    // MARK:- debuggin and error reporting
    public var notifiedErrors = [Error]()
    public func notifyError(_ error: NSError,
                            functionName: StaticString = #function,
                            fileName: StaticString = #file,
                            lineNumber: Int = #line,
                            callDetails: String) {
        notifiedErrors.append(error)
    }
    
    public var breadcrumbs = [String]()
    public func leaveBreadcrumb(with message: String, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        breadcrumbs.append(message)
    }
    
    public var updateHistoryCallCount: Int = 0
    public func updateHistory() {
        updateHistoryCallCount += 1
    }
    
    public var textCombiningHistoryAndSessionLogCallCount: Int = 0
    public func textCombiningHistoryAndSessionLog() -> String? {
        textCombiningHistoryAndSessionLogCallCount += 1
        return ""
    }
    
    var _userCanAccessDebugMenu: Bool = false
    public func userCanAccessDebugMenu() -> Bool {
        return _userCanAccessDebugMenu
    }
    
    public var loggedErrorMessages = [String]()
    public func error(message: String, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        loggedErrorMessages.append(message)
    }
    
    public var loggedErrors = [Error]()
    public func error(_ error: Error, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        loggedErrors.append(error)
    }
    
    public var debugMessages = [String]()
    public func debug(_ message: String, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        debugMessages.append(message)
    }
    
}
