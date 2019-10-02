
import Foundation

public class MockF4SAnalyticsAndDebugging : F4SAnalyticsAndDebugging {

    public init() {}
    
    // MARK: Analytics
    
    struct AnalyticsItem {
        enum ItemType {
            case screen
            case track
        }
        var type: ItemType
        var name: String
        var properties: [String : Any]?
        var options: [String :  Any]?
    }
    
    var analyticsItems = [AnalyticsItem]()
    var identities: [F4SUUID] = []
    public func identity(userId: F4SUUID) {
        identities.append(userId)
    }
    
    var aliases: [F4SUUID] = []
    public func alias(userId: F4SUUID) {
        aliases.append(userId)
    }
    
    public func track(event: String) {
        analyticsItems.append(AnalyticsItem(type: .track, name: event))
    }
    
    public func track(event: String, properties: [String : Any]) {
        analyticsItems.append(AnalyticsItem(type: .track, name: event, properties: properties))
    }
    
    public func track(event: String, properties: [String : Any], options: [String : Any]) {
        analyticsItems.append(AnalyticsItem(type: .track, name: event, properties: properties, options: options))
    }
    
    public func screen(title: String) {
        analyticsItems.append(AnalyticsItem(type: .screen, name: title))
    }
    
    public func screen(title: String, properties: [String : Any]) {
        analyticsItems.append(AnalyticsItem(type: .screen, name: title, properties: properties))
    }
    
    public func screen(title: String, properties: [String : Any], options: [String : Any]) {
        analyticsItems.append(AnalyticsItem(type: .screen, name: title, properties: properties, options: options))
    }
    
    // MARK:- debuggin and error reporting
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
