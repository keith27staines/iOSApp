
import WorkfinderCommon

typealias Headers = [String:String]

enum HeaderKeys : String {
    case wexApiKey = "wex.api.key"
}

/// Manages sessions for WEX services (will soon be abandoned in favour of
/// F4SNetworkSessionManager
public class WEXSessionManager {
    
    
    /// Initialises a new instance of the session manager
    ///
    /// - Parameter configuration: contains api keys and base urls for endpoints
    public init(configuration: WEXNetworkingConfigurationProtocol) {
        self.configuration = configuration
    }
    
    /// A session intended for general interactive use against the WEX api
    lazy public internal (set) var wexUserSession: URLSession = {
        makeWexUserSession()
    }()
    
    
    /// A session intended for downloading small images
    lazy public internal (set) var smallImageSession: URLSession = {
        makeSmallImageSession()
    }()
    
    // MARK:- Internal storage
    
    /// A singleton shared instance of the session manager
    static var shared: WEXSessionManager!
    
    let configuration: WEXNetworkingConfigurationProtocol
    
}

// MARK:- Implementation
extension WEXSessionManager {
    func makeSmallImageCache() -> URLCache {
        let memory = 5 * 1024 * 1024
        let disk = 10 * memory
        let diskpath = "smallImageCache"
        return URLCache(memoryCapacity: memory, diskCapacity: disk, diskPath: diskpath)
    }
    
    private func makeWexUserSession() -> URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = defaultHeaders
        return URLSession(configuration: configuration)
    }
    
    private func makeSmallImageSession() -> URLSession {
        return URLSession(configuration: makeSmallImageConfiguration())
    }
    
    func makeSmallImageConfiguration() -> URLSessionConfiguration {
        let configuration = URLSessionConfiguration.default
        configuration.allowsCellularAccess = true
        configuration.urlCache = makeSmallImageCache()
        configuration.requestCachePolicy = .useProtocolCachePolicy
        return configuration
    }
    
    var defaultHeaders: Headers {
        var headers = Headers()
        headers[HeaderKeys.wexApiKey.rawValue] = configuration.wexApiKey
        return headers
    }
}

