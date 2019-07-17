import Foundation
import WorkfinderCommon

public class F4SNetworkSessionManager {
    
    // MARK:- Public interface
    public let wexApiKey: String
    
    public static var shared: F4SNetworkSessionManager!
    
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
    
    public init(log: F4SAnalyticsAndDebugging?, wexApiKey: String = NetworkConfig.wexApiKey) {
        self.wexApiKey = wexApiKey
        logger = Logger(log: log)
    }
    
    // MARK:- Internal implementation
    
    internal var _interactiveSession: URLSession?
    internal var _smallImageSession: URLSession?
    
    internal var defaultHeaders : [String:String] {
        let header: [String : String] = ["wex.api.key": wexApiKey]
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
        let diskPath = "smallImageCache"
        let cache = URLCache(memoryCapacity: memory, diskCapacity: disk, diskPath: diskPath)
        configuration.urlCache = cache
        configuration.requestCachePolicy = .useProtocolCachePolicy
        return configuration
    }()
}

















