//
//  F4SService.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 06/01/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation
import KeychainSwift

public protocol F4SApiServiceProtocol {
    static var defaultHeaders : [String : String] { get }
    static var defaultConfiguration : URLSessionConfiguration { get }
    
    var session: URLSession { get }
    var baseUrl: URL { get }
    var apiName: String { get }
    var url: URL { get }
    var jsonDecoder: JSONDecoder { get }
    var jsonEncoder: JSONEncoder { get }
    
    /// Returns a URLSessionDatatask configued to perform a put against the workfinder api
    /// - parameter verb: Put or Patch Http verb
    /// - parameter objectToSend: The encodable object being sent to the server
    /// - parameter attempting: A high level description of the task being performed
    /// - parameter completion: The callback to return the result of the operation
    func sendDataTask<A:Encodable>(verb:F4SHttpSendRequestVerb, objectToSend:A, attempting: String, completion: @escaping (F4SNetworkDataResult) -> ()) -> URLSessionDataTask
    
    /// Returns a URLSessionDatatask configued to perform a get against the workfinder api
    /// - parameter attempting: A high level description of the task being performed
    /// - parameter completion: The callback to return the result of the operation
    func getDataTask<A>(attempting: String, completion: @escaping (F4SNetworkResult<A>) -> ()) -> URLSessionDataTask
}

public enum F4SHttpSendRequestVerb {
    case put
    case patch
    var name: String {
        switch self {
        case .put:
            return "PUT"
        case .patch:
            return "PATCH"
        }
    }
}

extension F4SApiServiceProtocol {
    
    /// Returns a dictionary of headers configured for use with the workfinder api
    public static var defaultHeaders : [String:String] {
        var header: [String : String] = ["wex.api.key": ApiConstants.apiKey]
        let keychain = KeychainSwift()
        if let userUuid = keychain.get(UserDefaultsKeys.userUuid) {
            header["wex.user.uuid"] = userUuid
        }
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

extension DateFormatter {
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}

public class F4SDataTaskService : F4SApiServiceProtocol {
    public lazy var jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
        return decoder
    }()
    
    public lazy var jsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(DateFormatter.iso8601Full)
        return encoder
    }()
    
    /// Returns a URLSessionDatatask configued to perform a put against the workfinder api
    /// - parameter verb: Put or Patch Http verb
    /// - parameter objectToSend: The encodable object being sent to the server
    /// - parameter attempting: A high level description of the task being performed
    /// - parameter completion: The callback to return the result of the operation
    public func sendDataTask<A:Encodable>(verb:F4SHttpSendRequestVerb, objectToSend:A, attempting: String, completion: @escaping (F4SNetworkDataResult) -> ()) -> URLSessionDataTask {
        
        var request = URLRequest(url: url)
        request.httpMethod = verb.name
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            request.httpBody = try jsonEncoder.encode(objectToSend)
        } catch {
            let networkError = F4SNetworkError(error: error, attempting: attempting)
            completion(F4SNetworkDataResult.error(networkError))
        }
        
        let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
            if let error = error as NSError? {
                let result = F4SNetworkDataResult.error(F4SNetworkError(error: error, attempting: attempting))
                completion(result)
                return
            }
            let httpResponse = response as! HTTPURLResponse
            if let error = F4SNetworkError(response: httpResponse, attempting: attempting) {
                let result = F4SNetworkDataResult.error(error)
                completion(result)
                return
            }
            completion(F4SNetworkDataResult.success(data))
        })
        return task
    }
    
    /// Returns a URLSessionDatatask configued to perform a get against the workfinder api
    /// - parameter attempting: A high level description of the task being performed
    /// - parameter completion: The callback to return the result of the operation
    public func getDataTask<A>(attempting: String, completion: @escaping (F4SNetworkResult<A>) -> ()) -> URLSessionDataTask {
        let task = session.dataTask(with: self.url) { (data, response, error) in
            if let error = error as NSError? {
                let result = F4SNetworkResult<A>.error(F4SNetworkError(error: error, attempting: attempting))
                completion(result)
                return
            }
            let httpResponse = response as! HTTPURLResponse
            if let error = F4SNetworkError(response: httpResponse, attempting: attempting) {
                let result = F4SNetworkResult<A>.error(error)
                completion(result)
                return
            }
            guard let data = data else {
                assertionFailure("No data to decode")
                let f4sError = F4SNetworkDataErrorType.noData.dataError(attempting: attempting)
                completion(F4SNetworkResult.error(f4sError))
                return
            }
            
            do {
                let value = try self.jsonDecoder.decode(A.self, from: data)
                let result = F4SNetworkResult.success(value)
                completion(result)
                return
            } catch (let error) {
                let f4sError = F4SNetworkDataErrorType.undecodableData(data).dataError(attempting: attempting + error.localizedDescription)
                log.debug("error attempting \(attempting), \n\(f4sError)")
                completion(F4SNetworkResult.error(f4sError))
                return
            }
        }
        return task
    }
    
    /// The dataTask currently being performed by this service (only one task can be in progress. Starting a second task will cancel the first)
    private var task: URLSessionDataTask?
    
    public let session: URLSession
    public let baseUrl: URL
    public var apiName: String { return self._apiName }
    private let _apiName: String
    public var url : URL {
        return URL(string: baseUrl.absoluteString + "/" + apiName)!
    }
    
    /// Initialize a new instance
    /// - parameter baseURLString: The base url
    /// - parameter apiName: The name of the api being called
    /// - parameter objectType: The type of the object that is to be instantiated from the response
    public init(baseURLString: String, apiName: String, objectType: Decodable.Type) {
        self._apiName = apiName
        self.baseUrl = URL(string: baseURLString)!
        session = URLSession(configuration: F4SRecommendationService.defaultConfiguration)
    }
    
    /// Performs an HTTP get request
    /// - parameter attempting: A short high level description of the reason the operation is being performed
    /// - parameter completion: Returns a result containing either the http response data or error information
    internal func get<A>(attempting: String, completion: @escaping (F4SNetworkResult<A>) -> ()) {
        task?.cancel()
        task = getDataTask(attempting: attempting, completion: { (result) in
            completion(result)
        })
        task?.resume()
    }
    
    /// Performs an HTTP request with a "send" very (e.g, put, patch, etc")
    /// - parameter verb: Http request verb
    /// - parameter object: The codable (json encodable) object to be patched to the server
    /// - parameter attempting: A short high level description of the reason the operation is being performed
    /// - parameter completion: Returns a result containing either the http response data or error information
    internal func send<A: Codable>(verb: F4SHttpSendRequestVerb, objectToSend: A, attempting: String, completion: @escaping (F4SNetworkDataResult) -> ()) {
        task?.cancel()
        task = sendDataTask(verb: verb, objectToSend: objectToSend, attempting: attempting, completion: { (result) in
            completion(result)
        })
        task?.resume()
    }
}
