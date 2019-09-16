public protocol F4SNetworkSessionManagerProtocol {
    /// `interactiveSession` is designed for services that connect to Workfinder which includes majority of services used in the app
    var interactiveSession: URLSession { get }
}
