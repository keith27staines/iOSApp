import Foundation
import WorkfinderCommon

public protocol F4SNetworkTaskFactoryProtocol {
    func urlRequest(verb: F4SHttpRequestVerb, url: URL, dataToSend: Data?) -> URLRequest
    func networkTask(verb: F4SHttpRequestVerb,
                     url: URL,
                     dataToSend: Data?,
                     attempting: String,
                     session: F4SNetworkSession,
                     completion: @escaping (F4SNetworkDataResult) -> ()) -> F4SNetworkTask
    
    func networkTask(with request: URLRequest,
                     session: F4SNetworkSession,
                     attempting: String,
                     completion: @escaping (F4SNetworkDataResult) -> ()) -> F4SNetworkTask
}

public class F4SNetworkTaskFactory : F4SNetworkTaskFactoryProtocol {
    
    let configuration: NetworkConfig
    
    /// Initalises a new instance of the factory
    ///
    /// - parameter configuration: An instance of `NetworkConfig`
    public init(configuration: NetworkConfig) {
        self.configuration = configuration
    }
    
    public func urlRequest(verb: F4SHttpRequestVerb, url: URL, dataToSend: Data?) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = verb.name
        request.httpBody = dataToSend
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }
    
    /// Returns a `F4SNetworkTask` that can be used independently
    public func networkTask(verb: F4SHttpRequestVerb,
                     url: URL,
                     dataToSend: Data?,
                     attempting: String,
                     session: F4SNetworkSession,
                     completion: @escaping (F4SNetworkDataResult) -> ()) -> F4SNetworkTask {
        let request =  urlRequest(verb: verb, url: url, dataToSend: dataToSend)
        return networkTask(with: request, session: session, attempting: attempting, completion: completion)
    }
    
    /// Returns a `F4SNetworkTask` that can be used independently
    public func networkTask(with request: URLRequest,
                     session: F4SNetworkSession,
                     attempting: String,
                     completion: @escaping (F4SNetworkDataResult) -> () ) -> F4SNetworkTask {
        var modifiedRequest = request
        if let userUuid = configuration.userRepository.loadCandidate().uuid  {
            modifiedRequest.setValue(userUuid, forHTTPHeaderField: "wex.user.uuid")
        }
        let logger = configuration.logger
        let task = session.networkTask(with: modifiedRequest, completionHandler: {data, response, error -> Void in
            if let error = error as NSError? {
                if error.domain == "NSURLErrorDomain" && error.code == -999 {
                    // The operation was cancelled
                    return
                }
                let result = F4SNetworkDataResult.error(F4SNetworkError(error: error, attempting: attempting))
                logger.logDataTaskFailure(attempting: attempting, error: error, request: modifiedRequest, response: nil, responseData: nil)
                completion(result)
                return
            }
            let httpResponse = response as! HTTPURLResponse
            if let error = F4SNetworkError(response: httpResponse, attempting: attempting) {
                logger.logDataTaskFailure(attempting: attempting, error: error, request: modifiedRequest, response: httpResponse, responseData: data)
                let result = F4SNetworkDataResult.error(error)
                completion(result)
                return
            }
            logger.logDataTaskSuccess(request: request, response: httpResponse, responseData: data!)
            completion(F4SNetworkDataResult.success(data))
        })
        return task
    }
}
