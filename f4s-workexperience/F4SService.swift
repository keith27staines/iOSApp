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

extension F4SApiService {
    
    /// Returns a URLSessionDatatask configued to perform a get against the workfinder api
    /// - parameter attempting: A high level description of the task being performed
    /// - parameter completion: The callback to return the result of the operation
    public func dataTask<A>(attempting: String, completion: @escaping (F4SNetworkResult<A>) -> ()) -> URLSessionDataTask {
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
    public let apiName: String
    
    public var url : URL {
        return URL(string: baseUrl.absoluteString + "/" + apiName)!
    }
    
    /// Initialize a new instance
    /// - parameter baseURLString: The base url
    /// - parameter apiName: The name of the api being called
    /// - parameter objectType: The type of the object that is to be instantiated from the response
    public init(baseURLString: String, apiName: String, objectType: Decodable.Type) {
        self.apiName = apiName
        self.baseUrl = URL(string: baseURLString)!
        session = URLSession(configuration: F4SRecommendationService.defaultConfiguration)
    }
    
    /// Performs an HTTP get request
    /// - parameter attempting: A short high level description of the reason the operation is being performed
    /// - parameter completion: Returns a result containing either the http response data or error information
    internal func get<A>(attempting: String, completion: @escaping (F4SNetworkResult<A>) -> ()) {
        task?.cancel()
        task = dataTask(attempting: attempting, completion: { (result) in
            completion(result)
        })
        task?.resume()
    }
}
