import WorkfinderCommon
import WorkfinderNetworking

/// Defines the two main functions of a network task
/// This protocol was introduced to hide the complexity of the interface of
/// URLSessionDataTask and simplify mocking of URLSessionDataTask in unit tests
public protocol F4SNetworkTask {
    /// Cancels (or attempts to cancel) the network task if it is running
    func cancel()
    /// Starts or resumes a network task (cannot be called on a cancelled task)
    func resume()
}

/// `F4SNetworkSession` defines a very simplified interface for URLSession
/// and was introduced to allow simpler mocking of URLSession in unit tests
public protocol F4SNetworkSession {
    func networkTask(with: URLRequest, completionHandler: @escaping ((Data?, URLResponse?, Error?) -> Void) ) -> F4SNetworkTask
    var configuration: URLSessionConfiguration { get }
}

/// Conform URLSession to F4SNetworkSession to enable simple mocking of URLSession
extension URLSession : F4SNetworkSession {
    public func networkTask(with request: URLRequest, completionHandler: @escaping ((Data?, URLResponse?, Error?) -> Void)) -> F4SNetworkTask {
        return self.dataTask(with: request, completionHandler: completionHandler)
    }
}

/// Conform URLSessionDataTask to F4SNetworkTask to simplify mocking
extension URLSessionDataTask : F4SNetworkTask {}




