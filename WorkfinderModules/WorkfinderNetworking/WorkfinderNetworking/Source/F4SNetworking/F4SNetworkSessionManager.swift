import Foundation
import WorkfinderCommon

public class F4SNetworkSessionManager {
    
    // MARK:- Public interface
    
    public static var shared: F4SNetworkSessionManager!
    let log: F4SAnalyticsAndDebugging?
    
    public var interactiveSession: URLSession {
        if _interactiveSession == nil {
            _interactiveSession = URLSession(configuration: interactiveConfiguration)
        }
        return _interactiveSession!
    }
    
    public var smallImageSession: URLSession {
        if _smallImageSession == nil {
            _smallImageSession = URLSession(configuration: smallImageConfiguration)
        }
        return _smallImageSession!
    }
    
    // MARK:- Internal implementation
    
    internal var _interactiveSession: URLSession?
    internal var _smallImageSession: URLSession?
    internal var _firstRegistrationSession: URLSession?
    
    public init(log: F4SAnalyticsAndDebugging?) {
        self.log = log
    }
    
    internal var defaultHeaders : [String:String] {
        let header: [String : String] = ["wex.api.key": ApiConstants.apiKey]
        return header
    }
    
    internal lazy var interactiveConfiguration: URLSessionConfiguration = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = defaultHeaders
        configuration.allowsCellularAccess = true
        return configuration
    }()
    
    internal lazy var smallImageConfiguration: URLSessionConfiguration = {
        let configuration = URLSessionConfiguration.default
        configuration.allowsCellularAccess = true
        let memory = 5 * 1024 * 1024
        let disk = 10 * memory
        let name = "smallImageCache"
        let cache = URLCache(memoryCapacity: memory, diskCapacity: disk, diskPath: name)
        configuration.urlCache = cache
        configuration.requestCachePolicy = .useProtocolCachePolicy
        return configuration
    }()
}

















