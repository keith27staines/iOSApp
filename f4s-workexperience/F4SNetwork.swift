//
//  F4SNetwork.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 07/01/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation

public typealias HTTPStatusCode = Int

public enum F4SNetworkResult<A:Decodable> {
    case error(F4SNetworkError)
    case success(A)
}

public enum F4SNetworkErrorDomainType : String {
    case client
    case server
}

public struct F4SNetworkError : Error {

    public private (set) var domainType: F4SNetworkErrorDomainType
    
    public var localizedDescription: String {
        return self.nsError.localizedDescription
    }
    public private (set) var nsError: NSError
    
    public var response: HTTPURLResponse? {
        return nsError.userInfo["response"] as? HTTPURLResponse
    }
    public var httpStatusCode:  HTTPStatusCode? {
        return self.response?.statusCode
    }
    public var localizedFailureReason: String? {
        return nsError.localizedFailureReason
    }
    public var localizedRecoveryOptions: [String]? {
        return nsError.localizedRecoveryOptions
    }
    public var localized: String? {
        return nsError.localizedRecoverySuggestion
    }
    
    public private (set) var retry: Bool = false
    
    public init(error: Error) {
        nsError = error as NSError
        let code = nsError.code
        domainType = .client
        switch code {
        case NSURLErrorNetworkConnectionLost, NSURLErrorNotConnectedToInternet:
            retry = true
        default:
            retry = false
        }
    }
    
    ///
    public init?(response: HTTPURLResponse, attempting: String) {
        var retry = false
        var userInfo : [String : Any] = ["response": response, "attempting": attempting]
        switch response.statusCode {
        case 200:
            return nil
        case 401:
            userInfo[NSLocalizedFailureReasonErrorKey] = "The user's credentials were not provided or are incorrect"
        case 403:
            userInfo[NSLocalizedFailureReasonErrorKey] = "The user doesn’t have access to this method"
        case 404:
            userInfo[NSLocalizedFailureReasonErrorKey] = "The URL was not found"
        case 429:
            userInfo[NSLocalizedFailureReasonErrorKey] = "The server refused this request because it has received too many requests from this client"
            retry = true
        case 500:
            userInfo[NSLocalizedFailureReasonErrorKey] = "The request was badly formed (somme parameters were incorrect or missing)"
        default:
            userInfo[NSLocalizedFailureReasonErrorKey] = "Unknown reason"
        }
        let nsError = NSError(domain: "HTTP", code: response.statusCode, userInfo: userInfo)
        self.init(error: nsError)
        domainType = .server
        self.retry = retry
    }
}
