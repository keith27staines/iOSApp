/// `NetworkConfig` defines api keys and api endpoints
public struct NetworkConfig {
    
    /// `wexApiKey` is the api key required for all calls to the Workfinder API
    public let wexApiKey: String
    
    /// The full url for the v2 api
    public var workfinderApiV3: String { return endpoints.workfinderApiUrlString }
    
    /// Manages network sessions
    public let sessionManager: F4SNetworkSessionManagerProtocol
    
    public func buildUrlRequest(url: URL, verb: F4SHttpRequestVerb, body: Data?) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpBody = body
        request.httpMethod = verb.name
        if let token = userRepository.loadAccessToken() {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
    
    /// A logger designed to capture full details of network errors
    public let logger: NetworkCallLoggerProtocol
    
    public let endpoints: WorkfinderEndpoint!
    
    public let userRepository: UserRepositoryProtocol
    
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
        userRepository: UserRepositoryProtocol) {
        self.logger = logger
        self.wexApiKey = workfinderApiKey
        self.sessionManager = sessionManager
        self.endpoints = endpoints
        self.userRepository = userRepository
    }
}




