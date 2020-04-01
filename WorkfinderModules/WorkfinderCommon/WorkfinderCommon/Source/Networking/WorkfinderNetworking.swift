/// `NetworkConfig` defines api keys and api endpoints
public struct NetworkConfig {
    
    /// `wexApiKey` is the api key required for all calls to the Workfinder API
    public let wexApiKey: String
    
    /// The full url for the v2 api
    public var workfinderApiV3: String { return endpoints.workfinderApiUrlString }
    
    /// Manages network sessions
    public let sessionManager: F4SNetworkSessionManagerProtocol
    
    /// A logger designed to capture full details of network errors
    public let logger: NetworkCallLoggerProtocol
    
    public let endpoints: WorkfinderEndpoint!
    
    public let userRepository: F4SUserRepositoryProtocol
    
    /// Initialise a new instance
    ///
    /// - Parameters:
    ///   - workfinderApiKey: the api key required for Workfinder api access
    ///   - logger: logs network failures
    public init(
        workfinderApiKey: String,
        logger: NetworkCallLoggerProtocol,
        sessionManager: F4SNetworkSessionManagerProtocol,
        endpoints: WorkfinderEndpoint,
        userRepository: F4SUserRepositoryProtocol) {
        self.logger = logger
        self.wexApiKey = workfinderApiKey
        self.sessionManager = sessionManager
        self.endpoints = endpoints
        self.userRepository = userRepository
    }
}




