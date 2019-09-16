import Foundation
import WorkfinderCommon

public protocol F4SNetworkSessionManagerProtocol {
    /// `interactiveSession` is designed for services that connect to Workfinder
    /// which includes majority of services used in the app
    var interactiveSession: URLSession { get }
}

/// `F4SNetworkSessionManager` manages almost all network sessions for the app.
/// Only three services are currently not directed through these sessions. They
/// use the now deprecated `WEXSessionManager` which was introduced only to
/// work around a problem in `F4SNetworkSessionManager` that is now fully
/// resolved. Becuase the large majority of services in the app use
/// `F4SNetworkSessionManager` and `WEXSessionManager` essentially implements
/// the same functionality, `F4SNetworkSessionManager` will be retained and
/// 'WEXSessionManager' will, with only a little more work, be obsolete and can
/// then be removed from the project
public class F4SNetworkSessionManager: F4SNetworkSessionManagerProtocol {
    
    /// The api key used in all Workfinder services
    public let wexApiKey: String
    
    /// `interactiveSession` is designed for services that connect to Workfinder
    /// which includes majority of services used in the app
    public var interactiveSession: URLSession {
        if _interactiveSession == nil {
            _interactiveSession = URLSession(configuration: interactiveConfiguration)
        }
        return _interactiveSession!
    }
    
    /// `smallImageSession` is designed for downloading icons from 3rd parties
    public var smallImageSession: URLSession {
        if _smallImageSession == nil {
            _smallImageSession = URLSession(configuration: smallImageConfiguration)
        }
        return _smallImageSession!
    }
    
    /// Creates a new instance and configures it with the specified api key
    init(wexApiKey: String) {
        self.wexApiKey = wexApiKey
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

















