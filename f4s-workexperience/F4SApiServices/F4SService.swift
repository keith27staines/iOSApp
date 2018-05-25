//
//  F4SService.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 06/01/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation
import KeychainSwift

public protocol F4SApiService {
    static var defaultHeaders : [String : String] { get }
    static var defaultConfiguration : URLSessionConfiguration { get }
    var session: URLSession { get }
    var baseUrl: URL { get }
    var apiName: String { get }
    var url: URL { get }
}

public enum F4SHttpRequestVerb {
    case get
    case put
    case patch
    var name: String {
        switch self {
        case .get:
            return "GET"
        case .put:
            return "PUT"
        case .patch:
            return "PATCH"
        }
    }
}

extension F4SApiService {
    /// Returns a URLSessionDatatask configued to perform a put against the workfinder api
    /// - parameter verb: Put or Patch Http verb
    /// - parameter object: The Codable object being sent to the server
    /// - parameter attempting: A high level description of the task being performed
    /// - parameter completion: The callback to return the result of the operation
    public func putDataTask<A:Codable,B:Codable>(verb:F4SHttpRequestVerb, object:A, attempting: String, completion: @escaping (F4SNetworkResult<B>) -> ()) -> URLSessionDataTask {
        
        var request = URLRequest(url: url)
        request.httpMethod = verb.name
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(object)
        } catch {
            let networkError = F4SNetworkError(error: error, attempting: attempting)
            completion(F4SNetworkResult.error(networkError))
        }
        
        let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
            if let error = error as NSError? {
                let result = F4SNetworkResult<B>.error(F4SNetworkError(error: error, attempting: attempting))
                completion(result)
                return
            }
            let httpResponse = response as! HTTPURLResponse
            if let error = F4SNetworkError(response: httpResponse, attempting: attempting) {
                let result = F4SNetworkResult<B>.error(error)
                completion(result)
                return
            }
            guard let data = data else {
                assertionFailure("No data to decode")
                let f4sError = F4SNetworkDataErrorType.noData.dataError(attempting: attempting)
                completion(F4SNetworkResult.error(f4sError))
                return
            }
            let decoder = JSONDecoder()
            do {
                let value = try decoder.decode(B.self, from: data)
                let result = F4SNetworkResult.success(value)
                completion(result)
                return
            } catch (let error) {
                let f4sError = F4SNetworkDataErrorType.undecodableData(data).dataError(attempting: attempting + error.localizedDescription)
                log.debug("error attempting \(attempting), \n\(f4sError)")
                completion(F4SNetworkResult.error(f4sError))
                return
            }
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
            let decoder = JSONDecoder()
            do {
                let value = try decoder.decode(A.self, from: data)
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

public class F4SDataTaskService : F4SApiService {
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
    
    /// Performs an HTTP post request
    /// - parameter object: The codable (json encodable) object to be posted to the server
    /// - parameter attempting: A short high level description of the reason the operation is being performed
    /// - parameter completion: Returns a result containing either the http response data or error information
    internal func put<A: Codable>(object: A, attempting: String, completion: @escaping (F4SNetworkResult<A>) -> ()) {
        task?.cancel()
        task = putDataTask(verb: .put, object: object, attempting: attempting, completion: { (result) in
            completion(result)
        })
        task?.resume()
    }
    
    
    /// Performs an HTTP patch request
    /// - parameter object: The codable (json encodable) object to be patched to the server
    /// - parameter attempting: A short high level description of the reason the operation is being performed
    /// - parameter completion: Returns a result containing either the http response data or error information
    internal func patch<A: Codable>(object: A, attempting: String, completion: @escaping (F4SNetworkResult<String>) -> ()) {
        task?.cancel()
        task = putDataTask(verb: .patch, object: object, attempting: attempting, completion: { (result) in
            completion(result)
        })
        
        task?.resume()
    }
}
