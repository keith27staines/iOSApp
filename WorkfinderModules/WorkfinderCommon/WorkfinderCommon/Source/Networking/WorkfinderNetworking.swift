/// `NetworkConfig` defines api keys and api endpoints
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
    ///   - logger: logs network failures
    public init(
        workfinderApiKey: String,
        workfinderBaseApi: String,
        logger: NetworkCallLoggerProtocol,
        sessionManager: F4SNetworkSessionManagerProtocol,
        endpoints: WorkfinderEndpoint) {
        self.logger = logger
        self.workfinderApi = workfinderBaseApi
        self.workfinderApiV2 = "\(workfinderBaseApi)/v2"
        self.wexApiKey = workfinderApiKey
        self.sessionManager = sessionManager
        self.endpoints = endpoints
    }
}




