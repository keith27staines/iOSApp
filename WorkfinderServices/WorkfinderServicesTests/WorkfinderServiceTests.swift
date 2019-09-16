import WorkfinderCommon

func makeTestConfiguration() -> NetworkConfig {
    let apiKey = "apiKey"
    let baseUrlString = "apiBaseUrl"
    let sessionManager = MockF4SNetworkSessionManager()
    let logger = MockLogger()
    let endpoints = WorkfinderEndpoint(baseUrlString:baseUrlString)
    let config = NetworkConfig(
        workfinderApiKey: apiKey,
        workfinderBaseApi: baseUrlString,
        logger: logger,
        sessionManager: sessionManager,
        endpoints: endpoints)
    return config
}
