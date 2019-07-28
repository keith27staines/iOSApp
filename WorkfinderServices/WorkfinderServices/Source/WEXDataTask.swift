//
//  WEXDataTask.swift
//  WorkfinderNetworking
//
//  Created by Keith Dev on 27/07/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation
import WorkfinderCommon
import WorkfinderNetworking

public typealias WEXDataResult = WEXResult<Data?,WEXNetworkError>

public class WEXDataTask {
    var session: URLSession { return WorkfinderNetworking.sharedWEXSessionManager.wexUserSession }
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
        var headers = [String: String]()
        if let userUuid = F4SUser().uuid {
            headers["wex.user.uuid"] = userUuid
        }
        if let additionalHeaders = additionalHeaders {
            headers.merge(additionalHeaders) { (current, _) -> String in current }
        }
        self.additionalHeaders = headers
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
            dataTask = session.dataTask(with: urlRequest) { [weak self] responseData, response, error in
                guard let strongSelf = self else { return }
                let attempting = strongSelf.attempting
                let httpUrlResponse = response as? HTTPURLResponse
                strongSelf.responseData = responseData
                guard strongSelf.isSuccessResponse(httpUrlResponse) else {
                    guard let httpResponse = httpUrlResponse else {
                        let wexError = WEXErrorsFactory.networkErrorFrom(error: error!, attempting: strongSelf.attempting)
                        let result = WEXDataResult.failure(wexError)
                        logger?.logDataTaskFailure(attempting: attempting, error: wexError, request: urlRequest, response: httpUrlResponse, responseData: responseData)
                        strongSelf.completionHandler?(result)
                        return
                    }
                    let wexError = WEXErrorsFactory.networkErrorFrom(response: httpResponse, responseData: responseData, attempting: strongSelf.attempting)!
                    let result = WEXDataResult.failure(wexError)
                    logger?.logDataTaskFailure(attempting: attempting, error: wexError, request: urlRequest, response: httpUrlResponse, responseData: responseData)
                    strongSelf.completionHandler?(result)
                    return
                }
                logger?.logDataTaskSuccess(request: urlRequest, response: httpUrlResponse!, responseData: responseData!)
                strongSelf.completionHandler?(WEXDataResult.success(responseData))
            }
            dataTask?.resume()
        } catch let wexError as WEXNetworkError {
            let result = WEXDataResult.failure(wexError)
            logger?.logDataTaskFailure(attempting: attempting, error: wexError, request: urlRequest!, response: nil, responseData: responseData)
            completionHandler?(result)
        } catch let error {
            let wexError = WEXErrorsFactory.networkErrorFrom(error: error, attempting: attempting)
            assert(false, "Invalid URL: \(urlString)")
            let result = WEXDataResult.failure(wexError)
            completionHandler?(result)
        }
    }
    
    public func cancel() {
        dataTask?.cancel()
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
