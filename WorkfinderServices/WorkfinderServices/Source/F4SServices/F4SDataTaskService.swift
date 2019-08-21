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

protocol F4SNetworkTaskFactoryProtocol {
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
    
    var userUuid: F4SUUID?
    
    init(userUuid: F4SUUID?) {
        self.userUuid = userUuid
    }
    
    func urlRequest(verb: F4SHttpRequestVerb, url: URL, dataToSend: Data?) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = verb.name
        request.httpBody = dataToSend
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }
    
    /// Returns a `F4SNetworkTask` that can be used independently
    func networkTask(verb: F4SHttpRequestVerb,
                     url: URL,
                     dataToSend: Data?,
                     attempting: String,
                     session: F4SNetworkSession,
                     completion: @escaping (F4SNetworkDataResult) -> ()) -> F4SNetworkTask {
        let request =  urlRequest(verb: verb, url: url, dataToSend: dataToSend)
        return networkTask(with: request, session: session, attempting: attempting, completion: completion)
    }
    
    /// Returns a `F4SNetworkTask` that can be used independently
    func networkTask(with request: URLRequest,
                     session: F4SNetworkSession,
                     attempting: String,
                     completion: @escaping (F4SNetworkDataResult) -> () ) -> F4SNetworkTask {
        var modifiedRequest = request
        modifiedRequest.setValue(userUuid, forHTTPHeaderField: "wex.user.uuid")
        let task = session.networkTask(with: modifiedRequest, completionHandler: {data, response, error -> Void in
            if let error = error as NSError? {
                if error.domain == "NSURLErrorDomain" && error.code == -999 {
                    // The operation was cancelled
                    return
                }
                let result = F4SNetworkDataResult.error(F4SNetworkError(error: error, attempting: attempting))
                logger?.logDataTaskFailure(attempting: attempting, error: error, request: modifiedRequest, response: nil, responseData: nil)
                completion(result)
                return
            }
            let httpResponse = response as! HTTPURLResponse
            if let error = F4SNetworkError(response: httpResponse, attempting: attempting) {
                logger?.logDataTaskFailure(attempting: attempting, error: error, request: modifiedRequest, response: httpResponse, responseData: data)
                let result = F4SNetworkDataResult.error(error)
                completion(result)
                return
            }
            logger?.logDataTaskSuccess(request: request, response: httpResponse, responseData: data!)
            completion(F4SNetworkDataResult.success(data))
        })
        return task
    }
}

/// Base class providing common network service functionality
open class F4SDataTaskService : F4SNetworkTaskFactoryProtocol {
    
    let _apiName: String
    
    /// The session used by the service
    public internal (set) var session: F4SNetworkSession
    
    /// The base url of the api (e.g ...v2)
    public let baseUrl: URL
    
    /// The api name (e.g `placement` or `user/me`)
    public var apiName: String { return self._apiName }
    
    /// url relative to baseUrl/apiName (e.g `uuid/documents` when retrieving
    /// documents from ...v2/company/uuid/documents)
    public var relativeUrlString: String?
    
    /// The object returned by the datatask in the completion handler
    public typealias DataTaskReturn = (data:Data?, response:URLResponse?, error:Error?)
    
    /// Initialises a new instance
    public var url : URL {
        let apiUrl = URL(string: urlString)!
        guard let relativeUrlString = relativeUrlString else { return apiUrl }
        return apiUrl.appendingPathComponent(relativeUrlString)
    }
    
    /// Returns the base url string concatenated with the apiname
    var urlString: String {
        return baseUrl.absoluteString + "/" + apiName
    }
    
    static var userRepo: F4SUserRepositoryProtocol = F4SUserRepository(localStore: LocalStore())
    
    /// Initialize a new instance
    /// - parameter baseURLString: The base url
    /// - parameter apiName: The name of the api being called
    /// - parameter additionalHeaders: Any additional request headers beyond the standard wex headers
    public init(baseURLString: String,
                apiName: String,
                additionalHeaders: [String:Any]? = nil) {
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
    
    /// Cancels or attempts to cancel the current datatask
    public func cancel() {
        task?.cancel()
    }
    
    /// Performs an HTTP `GET` request and returns the result on the completion handler
    ///
    /// - parameter attempting: A short high level description of the reason the operation is being performed
    /// - parameter completion: Returns a result containing either the return object or error information
    public func beginGetRequest<A>(attempting: String, completion: @escaping (F4SNetworkResult<A>) -> ()) {
        task?.cancel()
        let request = urlRequest(verb: .get, url: url, dataToSend: nil)
        task = dataTask(with: request, attempting: attempting, completion: { [weak self] (result) in
            guard let strongSelf = self else { return }
            switch result {
            case .error(let error):
                completion(F4SNetworkResult.error(error))
            case .success(let dataOrNil):
                guard
                    let data = dataOrNil,
                    let jsonObject = try? strongSelf.jsonDecoder.decode(A.self, from: data) else {
                        let error = F4SNetworkDataErrorType.deserialization(dataOrNil).error(attempting: attempting)
                        completion(F4SNetworkResult.error(error))
                        return
                }
                completion(F4SNetworkResult.success(jsonObject))
            }
        })
        task?.resume()
    }
    
    /// Performs an HTTP request with a "send" verb (e.g, put, patch, etc") and
    /// returns the result on the completion handler
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
        let data = try! jsonEncoder.encode(objectToSend)
        let request = urlRequest(verb: verb, url: url, dataToSend: data)
        task = dataTask(with: request, attempting: attempting, completion: completion)
        task?.resume()
    }
    
    public func beginDelete(attempting: String, completion: @escaping (F4SNetworkDataResult) -> ()) {
        task?.cancel()
        let request = urlRequest(verb: .delete, url: url, dataToSend: nil)
        task = dataTask(with: request, attempting: attempting, completion: completion)
        task?.resume()
    }
    
    /// The dataTask currently being performed by this service (only one task can be in progress. Starting a second task will cancel the first)
    var task: F4SNetworkTask?
    
    /// A JSON decoder equipped to decode datetimes as used in the Workfinder api
    public lazy var jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
        return decoder
    }()
    
    /// A JSON encoder equipped to encode dates as required by the Workfinder api
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
        let factory = F4SNetworkTaskFactory(userUuid: F4SDataTaskService.userRepo.load().uuid)
        return factory.urlRequest(verb: verb, url: url, dataToSend: dataToSend)
    }
    
    func networkTask(verb: F4SHttpRequestVerb, url: URL, dataToSend: Data?, attempting: String, session: F4SNetworkSession, completion: @escaping (F4SNetworkDataResult) -> ()) -> F4SNetworkTask {
        let factory = F4SNetworkTaskFactory(userUuid: F4SDataTaskService.userRepo.load().uuid)
        return factory.networkTask(verb: verb,
                                   url: url,
                                   dataToSend: dataToSend,
                                   attempting: attempting,
                                   session: session,
                                   completion: completion)
    }
    
    func networkTask(with request: URLRequest,
                            session: F4SNetworkSession,
                            attempting: String,
                            completion: @escaping (F4SNetworkDataResult) -> ()) -> F4SNetworkTask {
        return F4SDataTaskService.networkTask(with: request,
                                              session: session,
                                              attempting: attempting,
                                              completion: completion)
    }
    
    /// Returns a `F4SNetworkTask` that can be used independently
    public static func networkTask(with request: URLRequest,
                                   session: F4SNetworkSession,
                                   attempting: String,
                                   completion: @escaping (F4SNetworkDataResult) -> ()
        ) -> F4SNetworkTask {
        let factory = F4SNetworkTaskFactory(userUuid: userRepo.load().uuid)
        return factory.networkTask(with: request, session: session, attempting: attempting, completion: completion)
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

