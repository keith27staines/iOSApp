import WorkfinderCommon

/*
 `WorkfinderNetworking` defines shared state required by the network stack
 */
public struct WorkfinderNetworking {
    public static var networkCallLogger: NetworkCallLogger? { return logger }
    
    /// `sharedWEXSessionManager` is deprecated. Most of its functionality is
    /// incorporated in its F4S equivalent. No new services should be built to
    /// rely on any component of WEXNetworking
    public static var sharedWEXSessionManager: WEXSessionManager!
    
    /// Configures the entire networking stack
    ///
    /// Currently, WorkfinderNetworking manages two stacks: F4SNetworking and
    /// WEXNetworking. WEXNetworking was an interim solution to a problem that
    /// has gone away, and it can be dropped entirely once the three
    /// remaining services that rely on it are rebuilt to use F4SNetworking
    ///
    /// - Note: Call this only once in the production code
    ///
    /// - Parameters:
    ///   - wexApiKey: the api key required for Workfinder api access
    ///   - workfinderBaseApi: The base url for the api, which is supplemented interally by v2 etc
    ///   - log: A logging mechanism in which network errors will be reported
    static public func configure(wexApiKey: String, workfinderBaseApi: String, log: F4SAnalyticsAndDebugging) {
        logger = Logger(log: log)
        NetworkConfig._workfinderBaseApiUrlString = workfinderBaseApi
        NetworkConfig._wexApiKey = wexApiKey
        let config: WEXNetworkingConfigurationProtocol = WEXNetworkingConfiguration(
            wexApiKey: wexApiKey,
            baseUrlString: NetworkConfig.workfinderApi,
            v2ApiUrlString: NetworkConfig.workfinderApiV2)
        F4SNetworkSessionManager.shared = F4SNetworkSessionManager(wexApiKey: wexApiKey)
        sharedWEXSessionManager = WEXSessionManager(configuration: config)
    }
    
    
    static var _networkConfig: NetworkConfig!

}

/// `NetworkConfig` defines api keys and api endpoints which are exposed through
/// static methods which are set by `WorkfinderNetworking.configure`
public struct NetworkConfig {
    
    /// `wexApiKey` is the api key required for all calls to Workfinder
    public static var wexApiKey: String { return _wexApiKey }
    internal static var _wexApiKey: String = ""
    
    /// The base url for the Workfinder api, excluding the v2 postfixe
    public static var workfinderApi: String { return _workfinderBaseApiUrlString }
    internal static var _workfinderBaseApiUrlString: String = ""
    
    /// The full url for the v2 api
    public static var workfinderApiV2: String { return "\(_workfinderBaseApiUrlString)/v2" }
    
}

/// `logger` provides a logging mechanism speclialised for network requests
var logger: Logger?




