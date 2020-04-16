/// `NetworkConfig` defines api keys and api endpoints
public struct NetworkConfig {
    
    /// The full url for the v2 api
    public var workfinderApiV3: String { return endpoints.workfinderApiUrlString }
    
    /// Manages network sessions
    public let sessionManager: F4SNetworkSessionManagerProtocol
    
    public func buildUrlRequest(url: URL, verb: RequestVerb, body: Data?) -> URLRequest {
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
        logger: NetworkCallLoggerProtocol,
        sessionManager: F4SNetworkSessionManagerProtocol,
        endpoints: WorkfinderEndpoint,
        userRepository: UserRepositoryProtocol) {
        self.logger = logger
        self.sessionManager = sessionManager
        self.endpoints = endpoints
        self.userRepository = userRepository
    }
}




