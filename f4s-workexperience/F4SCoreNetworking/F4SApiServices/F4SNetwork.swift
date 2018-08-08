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

public enum F4SNetworkDataResult {
    case error(F4SNetworkError)
    case success(Data?)
}

public enum F4SNetworkErrorDomainType : String {
    case client
    case server
}

public enum F4SNetworkDataErrorType {
    case noData
    case emptyData
    case deserialization(Data)
    case serialization(Encodable)
    case unknownError(Any?)
    case genericErrorWithRetry
    case badUrl(String)
    
    public func error(attempting: String, logError: Bool = true) -> F4SNetworkError {
        let nsError: NSError
        let code: Int
        var userInfo: [String : Any] = [:]
        switch self {
        case .noData, .emptyData:
            code = -1000
            userInfo["Type"] = "No data"
        case .deserialization(let data):
            code = -1100
            userInfo["Type"] = "Deserialization error"
            userInfo["dataToDeserialize"] = data
        case .serialization(let encodable):
            code = -1200
            userInfo["Type"] = "Serialization error"
            userInfo["objectToSerialize"] = encodable
        case .unknownError(let info):
            code = -1300
            userInfo["Type"] = "Unknown error"
            userInfo["info"] = info
        case .genericErrorWithRetry:
            code = -1400
            userInfo["Type"] = "Generic error with retry"
            let description = NSLocalizedString("Unknown error", comment: "")
            return F4SNetworkError(localizedDescription: description, attempting: attempting, retry: true)
        case .badUrl(let badUrlString):
            code = -1500
            userInfo["Type"] =  "Malformed url"
            userInfo["bad url string"] = badUrlString
            let description = NSLocalizedString("The requested url is invalid", comment: "")
            return F4SNetworkError(localizedDescription: description, attempting: attempting, retry: false)
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
    
    public fileprivate (set) var retry: Bool = false
    
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
    
    /// Initialize a generic error with optional retry 
    public init(localizedDescription: String, attempting: String, retry: Bool, logError: Bool = true) {
        let nsError = NSError(domain: "com.f4s", code: 0, userInfo: nil)
        self.init(error: nsError, attempting: attempting, logError: logError)
        self.retry = retry
    }
    
    
    
    /// Writes a description to the debug log (currently the Xcode console)
    private func writeToLog() {
        var msg = "F4SNetworkingError"
        if let attempting = attempting {
            msg += " attempting to: \(attempting)"
        }
        msg += "\ncode = \(code)"
        msg += "\ndomain = \(domainType.rawValue)"
        if let reason = nsError.localizedFailureReason {
            msg += "\nreason = \(reason)"
        }
        msg += "\nuserInfo = \(nsError.userInfo)"
        log.error(msg)
    }
    
    /// Initializes a new instance
    /// - parameter response: the http resonse this instance will wrap, unless the response code is a success in which case this initializer will fail
    /// - parameter attempting: A short description of the context of the error (this might just be the operation name or a higher level description of it)
    /// - parameter logError: If true the error will be written to the debug log
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
