import Foundation
import WorkfinderCommon

public protocol F4SNetworkTask {
    func cancel()
    func resume()
}

public protocol F4SNetworkSession {
    func networkTask(with: URLRequest, completionHandler: @escaping ((Data?, URLResponse?, Error?) -> Void) ) -> F4SNetworkTask
}

extension URLSession : F4SNetworkSession {
    public func networkTask(with request: URLRequest, completionHandler: @escaping ((Data?, URLResponse?, Error?) -> Void)) -> F4SNetworkTask {
        return self.dataTask(with: request, completionHandler: completionHandler)
    }
}

extension URLSessionDataTask : F4SNetworkTask {}

open class F4SDataTaskService {
    let _apiName: String
    public let session: F4SNetworkSession
    public let baseUrl: URL
    public var apiName: String { return self._apiName }
    public var relativeUrlString: String?
    public typealias DataTaskReturn = (data:Data?, response:URLResponse?, error:Error?)
    
    public var url : URL? {
        let apiUrl = URL(string: urlString)!
        guard let relativeUrlString = relativeUrlString else { return apiUrl }
        return apiUrl.appendingPathComponent(relativeUrlString)
    }
    
    var urlString: String {
        return baseUrl.absoluteString + "/" + apiName
    }
    
    /// Initialize a new instance
    /// - parameter baseURLString: The base url
    /// - parameter apiName: The name of the api being called
    /// - parameter additionalHeaders: Any additional request headers beyond the standard wex headers
    public init(baseURLString: String, apiName: String, additionalHeaders: [String:Any]? = nil) {
        self._apiName = apiName
        self.baseUrl = URL(string: baseURLString)!
        let config = F4SDataTaskService.defaultConfiguration
        if let additionalHeaders = additionalHeaders {
            config.httpAdditionalHeaders?.merge(additionalHeaders, uniquingKeysWith: { (current, new) -> Any in
                return new
            })
        }
        session = URLSession(configuration: config)
    }
    
    public func cancel() {
        task?.cancel()
    }
    
    /// Performs an HTTP get request
    /// - parameter attempting: A short high level description of the reason the operation is being performed
    /// - parameter completion: Returns a result containing either the return object or error information
    public func beginGetRequest<A>(attempting: String, completion: @escaping (F4SNetworkResult<A>) -> ()) {
        task?.cancel()
        guard let url = url else {
            let error = F4SNetworkDataErrorType.badUrl(self.urlString).error(attempting: attempting)
            completion(F4SNetworkResult.error(error))
            return
        }
        let request = urlRequest(verb: .get, url: url, dataToSend: nil)
        task = dataTask(with: request, attempting: attempting, completion: { [weak self] (result) in
            guard let strongSelf = self else { return }
            switch result {
            case .error(let error):
                completion(F4SNetworkResult.error(error))
            case .success(let data):
                guard let data = data else {
                    let error = F4SNetworkDataErrorType.noData.error(attempting: attempting)
                    completion(F4SNetworkResult.error(error))
                    return
                }
                guard let jsonObject = try? strongSelf.jsonDecoder.decode(A.self, from: data) else {
                    let error = F4SNetworkDataErrorType.deserialization(data).error(attempting: attempting)
                    completion(F4SNetworkResult.error(error))
                    return
                }
                completion(F4SNetworkResult.success(jsonObject))
            }
        })
        task?.resume()
    }
    
    /// Performs an HTTP request with a "send" verb (e.g, put, patch, etc")
    ///
    /// - parameter verb: Http request verb
    /// - parameter object: The codable (json encodable) object to be patched to the server
    /// - parameter attempting: A short high level description of the reason the operation is being performed
    /// - parameter completion: Returns a result containing either the http response data or error information
    public func beginSendRequest<A: Codable>(verb: F4SHttpRequestVerb,
                                             objectToSend: A,
                                             attempting: String,
                                             completion: @escaping (F4SNetworkDataResult) -> ()
                                             ) {
        task?.cancel()
        guard let url = url else {
            let error = F4SNetworkDataErrorType.badUrl(urlString).error(attempting: attempting)
            completion(F4SNetworkDataResult.error(error))
            return
        }
        guard let data = try? jsonEncoder.encode(objectToSend) else {
            let error = F4SNetworkDataErrorType.serialization(objectToSend).error(attempting: attempting)
            completion(F4SNetworkDataResult.error(error))
            return
        }
        let request = urlRequest(verb: verb, url: url, dataToSend: data)
        task = dataTask(with: request, attempting: attempting, completion: completion)
        task?.resume()
    }
    
    public func beginDelete(attempting: String, completion: @escaping (F4SNetworkDataResult) -> ()) {
        task?.cancel()
        guard let url = url else {
            let error = F4SNetworkDataErrorType.badUrl(urlString).error(attempting: attempting)
            completion(F4SNetworkDataResult.error(error))
            return
        }
        let request = urlRequest(verb: .delete, url: url, dataToSend: nil)
        task = dataTask(with: request, attempting: attempting, completion: completion)
        task?.resume()
    }

    /// The dataTask currently being performed by this service (only one task can be in progress. Starting a second task will cancel the first)
    var task: F4SNetworkTask?
    
    public lazy var jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
        return decoder
    }()
    
    internal lazy var jsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(DateFormatter.iso8601Full)
        encoder.outputFormatting = .prettyPrinted
        return encoder
    }()
    
    public func urlRequest(verb: F4SHttpRequestVerb, url: URL, dataToSend: Data?) -> URLRequest {
        return F4SDataTaskService.urlRequest(verb:verb, url: url, dataToSend: dataToSend)
    }
    
    public static func urlRequest(verb: F4SHttpRequestVerb, url: URL, dataToSend: Data?) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = verb.name
        request.httpBody = dataToSend
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }
    
    public static func networkTask(with request: URLRequest,
                                session: F4SNetworkSession,
                                attempting: String,
                                completion: @escaping (F4SNetworkDataResult) -> ()
                                ) -> F4SNetworkTask {
        var modifiedRequest = request
        if let userUuid = F4SUser().uuid {
            modifiedRequest.setValue(userUuid, forHTTPHeaderField: "wex.user.uuid")
        }
        let task = session.networkTask(with: modifiedRequest, completionHandler: {data, response, error -> Void in
            if let error = error as NSError? {
                if error.domain == "NSURLErrorDomain" && error.code == -999 {
                    // The operation was cancelled
                    return
                }
                let result = F4SNetworkDataResult.error(F4SNetworkError(error: error, attempting: attempting))
                logger.logDataTaskFailure(error: error, request: modifiedRequest, response: nil, responseData: nil)
                completion(result)
                return
            }
            let httpResponse = response as! HTTPURLResponse
            if let error = F4SNetworkError(response: httpResponse, attempting: attempting) {
                logger.logDataTaskFailure(error: error, request: modifiedRequest, response: httpResponse, responseData: data)
                let result = F4SNetworkDataResult.error(error)
                completion(result)
                return
            }
            logger.logDataTaskSuccess(request: request, response: httpResponse, responseData: data!)
            completion(F4SNetworkDataResult.success(data))
        })
        return task
    }
    
    internal func dataTask(with request: URLRequest,
                           attempting: String,
                           completion: @escaping (F4SNetworkDataResult) -> ()
                           ) -> F4SNetworkTask {
        return F4SDataTaskService.networkTask(with: request, session: session, attempting: attempting, completion: completion)
    }
}

extension F4SDataTaskService {
    /// Returns a dictionary of headers configured for use with the workfinder api
    public static var defaultHeaders : [String:String] {
        let header: [String : String] = ["wex.api.key": NetworkConfig.wexApiKey]
        return header
    }

    /// Returns a URLSessionConfiguration configured with appropriate parameters
    public static var defaultConfiguration : URLSessionConfiguration {
        let session = URLSessionConfiguration.default
        session.allowsCellularAccess = true
        session.httpAdditionalHeaders = defaultHeaders
        return session
    }
}


