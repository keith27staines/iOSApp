//
//  F4SNetwork.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 07/01/2018.
//  Copyright © 2018 Workfinder Ltd. All rights reserved.
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
    case operationCancelled
    case badParameters
    case custom(title: String, description: String)
    case programmingError

    public var code: Int {
        switch self {
        // http error responses
        case .http(_, let response, _): return response?.statusCode ?? unexpectedErrorCode
        // start workfinder errors from 1000 reserving space below for http response codes
        case .error: return 1000
        case .notImplementedYet: return 1001
        case .invalidUrl(_): return 1002
        case .deserialization(_): return 1003
        case .noData: return 1004
        case .networkConnectivity: return 1005
        case .operationCancelled: return 1006
        case .badParameters: return 1007
        case .programmingError: return 1900
        case .custom(_,_): return unexpectedErrorCode - 1
        }
    }
    
    public var title: String {
        let code = " \(self.code)"
        switch self {
        case .error: return "Unexpected error" + code
        case .notImplementedYet: return "Not implemented" + code
        case .invalidUrl(_): return "Invalid Url" + code
        case .deserialization(_): return "Deserialization error" + code
        case .noData: return "No data" + code
        case .http(_,let response, _):
            guard let response = response else { return "No https response data" + code }
            switch response.statusCode {
            case 200...299: return "Error handling error" + code
            default: return "Server error" + code
            }
        case .networkConnectivity: return "Cannot contact server" + code
        case .operationCancelled: return "Operation cancelled"
        case .badParameters: return "Bad parameters"
        case .programmingError: return "Something went wrong"
        case .custom(let title,_): return title
        }
    }
    
    public var shouldNotify: Bool {
        switch self {
        case .error(_): return true
        case .notImplementedYet: return true
        case .invalidUrl(_): return true
        case .deserialization(_): return true
        case .noData: return true
        case .http(request: _, response: _, data: _): return true
        case .networkConnectivity: return false
        case .operationCancelled: return false
        case .badParameters: return true
        case .programmingError: return true
        case .custom(title: _, description: _): return true
        }
    }
    
    public var description: String {
        switch self {
        case .error(let nsError): return "An unexpected error has occurred. We are looking into it.\n\(nsError.localizedDescription)\(nsError.userInfo))"
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
        case .operationCancelled: return "The operation was cancelled"
        case .badParameters: return "One or more of the parameters sent to an api was invalid"
        case .programmingError: return "An internal error occurred"
        case .custom(_,let description): return description
        }
    }
    
    public var retry: Bool {
        switch self {
        case .networkConnectivity: return true
        default:
            switch self.code {
            case 501...599: return true
            default: return false
            }
        }
    }
}

public typealias HTTPStatusCode = Int

public class WorkfinderError: Error {

    public let errorType: WorkfinderErrorType
    public private (set) var _retry: Bool? = nil
    public var retry: Bool { _retry ?? errorType.retry }
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
                retryHandler: (() -> Void)? = nil) {
        self.errorType = errorType
        self.attempting = attempting
        self.retryHandler = retryHandler
    }
    
    public func asNSError() -> NSError {
        return NSError(domain: "Workfinder", code: code, userInfo: [
            "title" : title,
            "code" :  code,
            "description": description
            ]
        )
    }
    
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
        self.attempting = attempting
        self.retryHandler = retryHandler
    }
    
    public init(title: String, description: String, canRetry: Bool? = nil) {
        errorType = WorkfinderErrorType.custom(title: title, description: description)
        _retry = canRetry
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
