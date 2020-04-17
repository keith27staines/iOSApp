
/// `NetworkConfig` defines api keys and api endpoints
public let invalidBaseURLError: String = ""
public struct NetworkConfig {
    
    /// The full url for the v2 api
    public var workfinderApiV3: String { workfinderApiEndpoint.workfinderApiUrlString }
    public var workfinderApiV3Url: URL
    
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
    
    public let workfinderApiEndpoint: WorkfinderEndpoint!
    
    public let userRepository: UserRepositoryProtocol
    
    /// Initialise a new instance
    ///
    /// - Parameters:
    ///   - logger: logs network failures
    ///   - sessionManager: Manages network sessions
    ///   - endpoints:
    public init(
        logger: NetworkCallLoggerProtocol,
        sessionManager: F4SNetworkSessionManagerProtocol,
        workfinderEndpoint: WorkfinderEndpoint,
        userRepository: UserRepositoryProtocol) {
        self.logger = logger
        self.workfinderApiV3Url = workfinderEndpoint.workfinderAPiUrl
        self.sessionManager = sessionManager
        self.workfinderApiEndpoint = workfinderEndpoint
        self.userRepository = userRepository
    }
}




