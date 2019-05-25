//
//  WorkfinderNetworking.swift
//  WorkfinderNetworking
//
//  Created by Keith Dev on 09/03/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import WorkfinderCommon

var sharedSessionManager: WEXSessionManager!

public func configureWEXSessionManager(configuration: WEXNetworkingConfigurationProtocol, userUuid: F4SUUID?) throws {
    guard sharedSessionManager == nil else { throw WEXNetworkConfigurationError.sessionManagerMayOnlyBeConfiguredOnce}
    sharedSessionManager = WEXSessionManager(configuration: configuration)
    if let uuid = userUuid {
        sharedSessionManager.rebuildWexUserSession(user: uuid)
    }
}

public func updateWEXSessionManagerWithUserUUID(_ uuid: F4SUUID) {
    sharedSessionManager.rebuildWexUserSession(user: uuid)
}

public enum WEXNetworkConfigurationError : Error {
    case sessionManagerMayOnlyBeConfiguredOnce
}

public enum WEXHTTPRequestVerb {
    case get
    case put(Data)
    case patch(Data)
    case post(Data)
    case delete
    
    var name: String {
        switch self {
        case .get: return "GET"
        case .put(_): return "PUT"
        case .patch: return "PATCH"
        case .post: return "POST"
        case .delete: return "DELETE"
        }
    }
}

public typealias WEXDataResult = WEXResult<Data?,WEXNetworkError>
public typealias HTTPHeaders = [String:String]

public class WEXDataTask {
    var session: URLSession { return sharedSessionManager.wexUserSession }
    let urlString: String
    let verb: WEXHTTPRequestVerb
    let additionalHeaders: HTTPHeaders?
    var requestData: Data?
    var responseData: Data?
    
    var url: URL?
    var urlRequest: URLRequest?
    var completionHandler: ((WEXDataResult) -> Void)?
    var dataTask: URLSessionDataTask?
    
    var attempting: String {
        return "\(self.verb.name): \(urlString)"
    }
    
    public init(urlString: String,
                verb: WEXHTTPRequestVerb,
                additionalHeaders: HTTPHeaders? = nil,
                completion: @escaping ((WEXDataResult) -> Void)) {
        self.urlString = urlString
        self.verb = verb
        switch verb {
        case .post(let payload), .put(let payload), .patch(let payload):
            self.requestData = payload
        default:
            self.requestData = nil
        }
        self.additionalHeaders = additionalHeaders
        self.completionHandler = completion
    }
    
    public func start() {
        do {
            responseData = nil
            dataTask?.cancel()
            let url = try makeUrl(urlString: urlString)
            self.url = url
            let urlRequest = makeUrlRequest(verb: verb, url: url, dataToSend: requestData, additionalHeaders: additionalHeaders)
            self.urlRequest = urlRequest
            dataTask = session.dataTask(with: urlRequest, completionHandler: handleDataTaskCompletion)
            dataTask?.resume()
        } catch let wexError as WEXNetworkError {
            let result = WEXDataResult.failure(wexError)
            completionHandler?(result)
        } catch let error {
            let wexError = WEXErrorsFactory.networkErrorFrom(error: error, attempting: attempting)
            let result = WEXDataResult.failure(wexError)
            completionHandler?(result)
        }
    }
    
    public func cancel() {
        dataTask?.cancel()
    }
    
    func handleDataTaskCompletion(responseData: Data?, response: URLResponse?, error: Error?) {
        let httpResponse = response as? HTTPURLResponse
        self.responseData = responseData
        guard isSuccessResponse(httpResponse) else {
            guard let httpResponse = httpResponse else {
                let wexError = WEXErrorsFactory.networkErrorFrom(error: error!, attempting: attempting)
                let result = WEXDataResult.failure(wexError)
                completionHandler?(result)
                return
            }
            let wexError = WEXErrorsFactory.networkErrorFrom(response: httpResponse, responseData: responseData, attempting: attempting)
            let result = WEXDataResult.failure(wexError!)
            completionHandler?(result)
            return
        }
        completionHandler?(WEXDataResult.success(responseData))
    }
    
    func isSuccessResponse(_ response: HTTPURLResponse?) -> Bool {
        guard let response = response, (200...299).contains(response.statusCode) else { return false }
        return true
    }
    
    func makeUrl(urlString: String) throws -> URL {
        guard let url = URL(string: urlString) else {
            throw WEXErrorsFactory.networkErrorFromInvalidUrlString(urlString, attempting: attempting)
        }
        return url
    }
        
    func makeUrlRequest(verb: WEXHTTPRequestVerb, url: URL, dataToSend: Data?, additionalHeaders: HTTPHeaders?) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = verb.name
        request.httpBody = dataToSend
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        guard let additionalHeaders = additionalHeaders else { return request }
        additionalHeaders.forEach { (key, value) in request.addValue(value, forHTTPHeaderField: key) }
        return request
    }
    
}
