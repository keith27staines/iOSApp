import WorkfinderCommon

public typealias HTTPHeaders = [String:String]

public enum WEXNetworkConfigurationError : Error {
    case sessionManagerMayOnlyBeConfiguredOnce
}

/*
 `WorkfinderNetworking` defines shared state required by the network stack
 */
public struct WorkfinderNetworking {
    public static var networkCallLogger: NetworkCallLogger? { return logger }
    public static var sharedWEXSessionManager: WEXSessionManager!
    
    /// Configures the entire networking stack
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

var logger: Logger?

public struct NetworkConfig {
    
    public static var wexApiKey: String { return _wexApiKey }
    internal static var _wexApiKey: String = ""
    
    /// The base url for the workfinder api, excluding v1 or v2 postfixes
    public static var workfinderApi: String { return _workfinderBaseApiUrlString }
    internal static var _workfinderBaseApiUrlString: String = ""
    
    /// The full url for the v2 api
    public static var workfinderApiV2: String { return "\(_workfinderBaseApiUrlString)/v2" }
    
}






