import WorkfinderCommon

func makeTestConfiguration(userUuid: F4SUUID? = nil) -> NetworkConfig {
    let apiKey = "apiKey"
    let baseUrlString = "apiBaseUrl"
    let sessionManager = MockF4SNetworkSessionManager()
    let logger = MockNetworkCallLogger()
    let endpoints = WorkfinderEndpoint(baseUrlString:baseUrlString)
    let user = F4SUser(uuid: userUuid)
    let userRepo = MockUserRepository(user: user)
    let config = NetworkConfig(
        workfinderApiKey: apiKey,
        logger: logger,
        sessionManager: sessionManager,
        endpoints: endpoints,
        userRepository: userRepo)
    return config
}
