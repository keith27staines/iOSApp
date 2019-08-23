//
//  F4SNetworkTaskFactory.swift
//  WorkfinderServices
//
//  Created by Keith Dev on 22/08/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation
import WorkfinderCommon
import WorkfinderNetworking

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
    
    /// Initalises a new instance of the factory
    ///
    /// - Parameter userUuid:  the user uuid to be used by the factory. If omitted, the factory uses the uuid from the user in the default local store
    init(userUuid: F4SUUID? = nil) {
        guard let userUuid = userUuid else {
            let userRepo = F4SUserRepository(localStore: LocalStore())
            self.userUuid = userRepo.load().uuid
            return
        }
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
