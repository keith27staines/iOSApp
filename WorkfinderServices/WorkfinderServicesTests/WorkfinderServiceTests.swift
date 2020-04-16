import WorkfinderCommon

func makeTestConfiguration(userUuid: F4SUUID? = nil) -> NetworkConfig {
    let baseUrlString = "apiBaseUrl"
    let sessionManager = MockF4SNetworkSessionManager()
    let logger = MockNetworkCallLogger()
    let endpoints = WorkfinderEndpoint(baseUrlString:baseUrlString)
    let user = User()
    let userRepo = MockUserRepository(user: user)
    let config = NetworkConfig(
        logger: logger,
        sessionManager: sessionManager,
        endpoints: endpoints,
        userRepository: userRepo)
    return config
}
