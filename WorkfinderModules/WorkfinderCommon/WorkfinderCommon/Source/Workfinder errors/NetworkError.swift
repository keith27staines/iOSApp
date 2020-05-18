//
//  F4SNetwork.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 07/01/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation
public let unexpectedErrorCode = 1202
public enum WorkfinderErrorType {
    case error(NSError)
    case notImplementedYet
    case invalidUrl(String)
    case deserialization(Error)
    case noData
    case http(request:URLRequest?, response:HTTPURLResponse?, data: Data?)
    case networkConnectivity
    case custom(title: String, description: String)
    
    var code: Int {
        switch self {
        // http error responses
        case .http(_, let response, _): return response?.statusCode ?? unexpectedErrorCode
            
        // start from 1000 allowing space for http response codes
        case .error: return 1000
        case .notImplementedYet: return 1001
        case .invalidUrl(_): return 1002
        case .deserialization(_): return 1003
        case .noData: return 1004
        case .networkConnectivity: return 1005
        case .custom(_,_): return unexpectedErrorCode - 1
        }
    }
    
    var title: String {
        switch self {
        case .error: return "1202 Unexpected error"
        case .notImplementedYet: return "Not implemented"
        case .invalidUrl(_): return "Invalid Url"
        case .deserialization(_): return "Deserialization error"
        case .noData: return "No data"
        case .http(_,let response, _):
            guard let response = response else { return "No https response data" }
            switch response.statusCode {
            case 200...299: return "Error handling error"
            default: return "Server error"
            }
        case .networkConnectivity: return "Cannot contact server"
        case .custom(let title,_): return title
        }
    }
    
    var description: String {
        switch self {
        case .error: return "An unexpected error has occurred. We are looking into it."
        case .notImplementedYet: return "Not implemented"
        case .invalidUrl(let url): return "The url \(url) is invalid"
        case .deserialization(let error): return error.localizedDescription
        case .noData: return "The operation returned no data"
        case .http(_, let response, _):
            guard let response = response else { return "No response" }
            switch response.statusCode {
            case 200...299: return "Unexpectedly generated an error from succesful request"
            case 400: return "Bad request"
            case 401: return "The user's credentials were not provided or are incorrect"
            case 403: return "The user doesn’t have access to this method"
            case 404: return "The URL was not found"
            case 429: return "The server refused this request because it has received too many requests from this client"
            case 500: return "The request was badly formed (some parameters were incorrect or missing)"
            case 502: return "Bad gateway"
            case 503: return "The server is unavailable"
            default: return "Server error"
            }
        case .networkConnectivity: return "Please make sure you have a good internet connection"
        case .custom(_,let description): return description
        }
    }
    
    var retry: Bool {
        switch self.code {
        case 501...599: return true
        default: return false
        }
    }
}

public typealias HTTPStatusCode = Int

public class WorkfinderError: Error {

    public let errorType: WorkfinderErrorType
    public var retry =  false
    public var retryHandler: (() -> Void)?

    public var underlyingError: NSError?
    public var attempting: String?
    public lazy var title: String = { self.errorType.title }()
    public lazy var description: String = { self.errorType.description }()
    public var code: Int { return self.errorType.code }
    public var urlRequest: URLRequest?
    public var httpResponse: HTTPURLResponse?
    public var responseData: Data?
    
    public init(errorType: WorkfinderErrorType,
                attempting: String?,
                retryHandler: (() -> Void)?) {
        self.errorType = errorType
        self.attempting = attempting
        self.retryHandler = retryHandler
    }
    
    /*
     NSURLErrorCannotFindHost = -1003,

     NSURLErrorCannotConnectToHost = -1004,

     NSURLErrorNetworkConnectionLost = -1005,

     NSURLErrorDNSLookupFailed = -1006,

     NSURLErrorHTTPTooManyRedirects = -1007,

     NSURLErrorResourceUnavailable = -1008,

     NSURLErrorNotConnectedToInternet = -1009,

     NSURLErrorRedirectToNonExistentLocation = -1010,

     NSURLErrorInternationalRoamingOff = -1018,

     NSURLErrorCallIsActive = -1019,

     NSURLErrorDataNotAllowed = -1020,

     NSURLErrorSecureConnectionFailed = -1200,

     NSURLErrorCannotLoadFromNetwork = -2000,
     */
    
    public init(from nsError: NSError,
                attempting: String? = nil,
                retryHandler: (() -> Void)?) {
        let errorCode = nsError.code
        let networkConnectionErrors = [
            NSURLErrorNotConnectedToInternet,
            NSURLErrorNetworkConnectionLost,
            NSURLErrorCannotConnectToHost,
            NSURLErrorTimedOut
        ]
        let isNetworkConnectivityProblem = networkConnectionErrors.contains(errorCode)
        self.errorType = isNetworkConnectivityProblem ? .networkConnectivity : .error(nsError)
        self.underlyingError = nsError
        self.retryHandler = retryHandler
    }
    
    public init(title: String, description: String) {
        errorType = WorkfinderErrorType.custom(title: title, description: description)
    }
    
    public convenience init?(request: URLRequest,
                             response: HTTPURLResponse,
                             data: Data,
                             retryHandler: (() -> Void)?) {
        guard !(200...299).contains(response.statusCode) else { return nil }
        self.init(
            errorType: WorkfinderErrorType.http(request: request,response: response, data: data),
            attempting: nil,
            retryHandler: retryHandler)
        self.urlRequest = request
        self.httpResponse = response
        self.responseData = data
    }
    
    public convenience init?(response: HTTPURLResponse, retryHandler: (() -> Void)?) {
        guard !(200...299).contains(response.statusCode) else { return nil }
        self.init(
            errorType: WorkfinderErrorType.http(request: nil,response: response, data: nil),
            attempting: nil,
            retryHandler: retryHandler)
        self.httpResponse = response
    }
}