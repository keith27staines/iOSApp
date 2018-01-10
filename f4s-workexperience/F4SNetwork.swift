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

public enum F4SNetworkDataErrorType {
    case noData
    case emptyData
    case undecodableData(Data)
    case unknownError(Any?)
    
    public func dataError(attempting: String, logError: Bool = true) -> F4SNetworkError {
        let nsError: NSError
        let code: Int
        var userInfo: [String : Any] = [:]
        switch self {
        case .noData, .emptyData:
            code = -1001
        case .undecodableData(let data):
            code = -1002
            userInfo["data"] = data
            userInfo["string"] = String(data: data, encoding: .utf8)
        case .unknownError(let info):
            code = -1003
            userInfo["info"] = info
        }
        nsError = NSError(domain: F4SNetworkErrorDomainType.client.rawValue, code: code, userInfo: userInfo)
        return F4SNetworkError(error: nsError, attempting: attempting, logError: logError)
    }
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
    public var code: String {
        return String(self.nsError.code)
    }
    public var localizedFailureReason: String? {
        return nsError.localizedFailureReason
    }
    public var localizedRecoveryOptions: [String]? {
        return nsError.localizedRecoveryOptions
    }
    public var localizedRecoverySuggestion: String? {
        return nsError.localizedRecoverySuggestion
    }
    
    public private (set) var attempting: String?
    
    public private (set) var retry: Bool = false
    
    /// Initializes a new instance
    /// - parameter error: the immediate error this instance will wrap]
    /// - parameter attempting: A short description of the context of the error (this might just be the operation name or a higher level description of it)
    /// - parameter logError: If true, the error will be written to the debug log
    public init(error: Error, attempting: String, logError: Bool = true) {
        nsError = error as NSError
        let code = nsError.code
        domainType = .client
        self.attempting = attempting
        switch code {
        case NSURLErrorNetworkConnectionLost, NSURLErrorNotConnectedToInternet:
            retry = true
        default:
            retry = false
        }
        if logError { writeToLog() }
    }
    
    /// Writes a description to the debug log (currently the Xcode console)
    private func writeToLog() {
        if let attempting = attempting {
            print("F4SNetworkError: attempting \(attempting) \n \(self)")
        } else {
            print("F4SNetworkError \(self)")
        }
        var msg = "F4SNetworkingError"
        if let attempting = attempting {
            msg += " attempting to: \(attempting)"
        }
        msg += "\ncode = code"
        msg += "\ndomain = \(domainType.rawValue)"
        if let reason = nsError.localizedFailureReason {
            msg += "\nreason = \(reason)"
        }
        msg += "\nuserInfo = \(nsError.userInfo)"
    }
    
    /// Initializes a new instance
    /// - parameter response: the http resonse this instance will wrap, unless the response code is a success in which case this initializer will fail
    /// - parameter attempting: A short description of the context of the error (this might just be the operation name or a higher level description of it)
    /// - parameter logError: If truem the error will be written to the debug log
    public init?(response: HTTPURLResponse, attempting: String, logError: Bool = true) {
        var retry = false
        var userInfo : [String : Any] = ["response": response]
        switch response.statusCode {
        case 200...299:
            return nil // These are success codes
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
            userInfo[NSLocalizedFailureReasonErrorKey] = "The request was badly formed (some parameters were incorrect or missing)"
        default:
            userInfo[NSLocalizedFailureReasonErrorKey] = "Unknown reason"
        }
        let nsError = NSError(domain: "HTTP", code: response.statusCode, userInfo: userInfo)
        self.init(error: nsError, attempting: attempting, logError: false)
        domainType = .server
        self.retry = retry
        if logError { writeToLog() }
    }
}
