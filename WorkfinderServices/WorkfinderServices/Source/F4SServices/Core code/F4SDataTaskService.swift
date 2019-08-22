import WorkfinderCommon
import WorkfinderNetworking

/// Base class providing common network service functionality
open class F4SDataTaskService {
    /// The api name (e.g `placement` or `user/me`)
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
    
    var networkTaskfactory: F4SNetworkTaskFactoryProtocol = F4SNetworkTaskFactory(userUuid: userRepo.load().uuid)
    
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
        task = networkTask(verb: .get, url: url, dataToSend: nil, attempting: attempting) { [weak self] (result) in
            guard let strongSelf = self else { return }
            strongSelf.processResult(result, attempting: attempting, completion: completion)
        }
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
        let data = try! jsonEncoder.encode(objectToSend)
        task?.cancel()
        task = networkTask(verb: verb, url: url, dataToSend: data, attempting: attempting, completion: completion)
        task?.resume()
    }
    
    func processResult<A:Decodable>(_ result: F4SNetworkDataResult, attempting: String, completion: @escaping (F4SNetworkResult<A>) -> ()) {
        switch result {
        case .error(let error):
            completion(F4SNetworkResult<A>.error(error))
        case .success(let data):
            guard let data = data else {
                let noDataError = F4SNetworkDataErrorType.noData.error(attempting: attempting)
                completion(F4SNetworkResult.error(noDataError))
                return
            }
            let decoder = self.jsonDecoder
            do {
                let decodedJson = try decoder.decode(A.self, from: data)
                completion(F4SNetworkResult.success(decodedJson))
            } catch {
                let error = F4SNetworkDataErrorType.deserialization(data).error(attempting: attempting)
                completion(F4SNetworkResult.error(error))
            }
        }
    }
    
    public func beginDelete(attempting: String, completion: @escaping (F4SNetworkDataResult) -> ()) {
        task?.cancel()
        task = networkTask(verb: .delete, url: url, dataToSend: nil, attempting: attempting, completion: completion)
        task?.resume()
    }
    
    /// The dataTask currently being performed by this service (only one task can be in progress. Starting a second task will cancel the first)
    var task: F4SNetworkTask?
    
    /// A Json decoder equipped to decode datetimes as used in the Workfinder api
    public lazy var jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
        return decoder
    }()
    
    /// A Json encoder equipped to encode dates as required by the Workfinder api
    internal lazy var jsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(DateFormatter.iso8601Full)
        encoder.outputFormatting = .prettyPrinted
        return encoder
    }()
    
    // TODO: Remove this function when all services converted to new model which eliminates need for this
    public static func urlRequest(verb: F4SHttpRequestVerb, url: URL, dataToSend: Data?) -> URLRequest {
        let factory = F4SNetworkTaskFactory(userUuid: F4SDataTaskService.userRepo.load().uuid)
        return factory.urlRequest(verb: verb, url: url, dataToSend: dataToSend)
    }
    
    func networkTask(verb: F4SHttpRequestVerb, url: URL, dataToSend: Data?, attempting: String, completion: @escaping (F4SNetworkDataResult) -> ()) -> F4SNetworkTask {
        return networkTaskfactory.networkTask(verb: verb,
                                   url: url,
                                   dataToSend: dataToSend,
                                   attempting: attempting,
                                   session: session,
                                   completion: completion)
    }
    
    func networkTask(with request: URLRequest,
                     attempting: String,
                     completion: @escaping (F4SNetworkDataResult) -> ()) -> F4SNetworkTask {
        return networkTaskfactory.networkTask(with: request, session: session, attempting: attempting, completion: completion)
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
