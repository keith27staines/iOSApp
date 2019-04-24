//
//  WEXNetworkingInterface.swift
//  WorkfinderCommon
//
//  Created by Keith Dev on 03/04/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation

public extension WEXErrorsFactory {
    public static func networkErrorFrom(response: HTTPURLResponse, data: Data?, attempting: String) -> WEXNetworkError? {
        return WEXNetworkError(response: response, data: data, attempting: attempting)
    }
    public static func networkErrorFrom(error: Error, attempting: String) -> WEXNetworkError {
        return WEXNetworkError(error: error, attempting: attempting)
    }
    public static func networkErrorFromInvalidUrlString(_ urlString: String, attempting: String) -> WEXNetworkError {
        return WEXNetworkError(localizedDescription: urlString, attempting: attempting, retry: false)
    }
    public static func networkNoDataReturnedError(attempting: String) -> WEXNetworkError {
        return WEXNetworkError(localizedDescription: "A valid response was obtained but the expected data was missing", attempting: attempting, retry: true)
    }
}

public typealias HttpStatusCode = Int

public struct WEXNetworkError : WEXError {
    public var nsError: NSError?
    public var localizedDescription: String
    public var response: HTTPURLResponse?
    public var httpStatusCode:  HttpStatusCode?
    public var code: Int?
    
    public var attempting: String?
    public var retry: Bool = false
    public var data: Data?
    
    /// Initializes a new instance
    /// - parameter error: the immediate error this instance will wrap]
    /// - parameter attempting: A short description of the context of the error (this might just be the operation name or a higher level description of it)
    init(error: Error, attempting: String) {
        nsError = error as NSError
        code = nsError!.code
        localizedDescription = nsError!.localizedDescription
        self.attempting = attempting
        switch code {
        case NSURLErrorNetworkConnectionLost, NSURLErrorNotConnectedToInternet:
            retry = true
        default:
            retry = false
        }
    }
    
    /// Initialize a generic error with optional retry
    init(localizedDescription: String, attempting: String, retry: Bool, logError: Bool = true) {
        self.localizedDescription = localizedDescription
        self.attempting = attempting
        self.retry = retry
    }
    
    /// Initializes a new instance
    /// - parameter response: the http resonse this instance will wrap, unless the response code is a success in which case this initializer will fail
    /// - parameter data: The data returned in the body of the failed request (if any)
    /// - parameter attempting: A short description of the context of the error (this might just be the operation name or a higher level description of it)
    init?(response: HTTPURLResponse, data: Data?, attempting: String) {
        retry = false
        self.response = response
        httpStatusCode = response.statusCode
        switch response.statusCode {
        case 200...299:
            return nil // These are success codes
        case 401:
            localizedDescription = "The user's credentials were not provided or are incorrect"
        case 403:
            localizedDescription = "The user doesn’t have access to this method"
        case 404:
            localizedDescription = "The URL was not found"
        case 429:
            localizedDescription = "The server refused this request because it has received too many requests from this client"
            retry = true
        case 500:
            localizedDescription = "Server error"
        default:
            localizedDescription = "Unknown reason"
        }
    }
}

