import WorkfinderCommon

/// `NetworkConfig` defines api keys and api endpoints which are exposed through
/// static methods which are set by `WorkfinderNetworking.configure`
public struct NetworkConfig {
    
    /// `wexApiKey` is the api key required for all calls to the Workfinder API
    public let wexApiKey: String
    
    /// The base url for the Workfinder api, excluding the v2 postfix
    public let workfinderApi: String
    
    /// The full url for the v2 api
    public let workfinderApiV2: String
    
    /// Manages network sessions
    public let sessionManager: F4SNetworkSessionManagerProtocol
    
    /// A logger designed to capture full details of network errors
    public let logger: NetworkCallLoggerProtocol
    
    public let endpoints: WorkfinderEndpoint!
    
    /// Initialise a new instance
    ///
    /// - Parameters:
    ///   - workfinderApiKey: the api key required for Workfinder api access
    ///   - workfinderBaseApi: The base url for the api, which is supplemented interally by v2 etc
    ///   - log: A logging mechanism in which network errors will be reported
    public init(
        workfinderApiKey: String,
        workfinderBaseApi: String,
        log: F4SAnalyticsAndDebugging) {
        self.logger = Logger(log: log)
        self.workfinderApi = workfinderBaseApi
        self.workfinderApiV2 = "\(workfinderBaseApi)/v2"
        self.wexApiKey = workfinderApiKey
        self.sessionManager = F4SNetworkSessionManager(wexApiKey: wexApiKey)
        self.endpoints = WorkfinderEndpoint(baseUrlString: workfinderBaseApi)
    }
}




