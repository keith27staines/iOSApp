//
//  Logger.swift
//  WorkfinderNetworking
//
//  Created by Keith Dev on 21/06/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation
import WorkfinderCommon

public protocol NetworkCallLogger {
    func logDataTaskFailure(attempting: String?,
    error: Error,
    request: URLRequest,
    response: HTTPURLResponse?,
    responseData: Data?)
    
    func logDataTaskSuccess(request: URLRequest,
                            response: HTTPURLResponse,
                            responseData: Data)
}

class Logger : NetworkCallLogger {
    
    let log: F4SAnalyticsAndDebugging?
    
    init(log: F4SAnalyticsAndDebugging?) {
        self.log = log
    }
    
    func logDataTaskFailure(attempting: String? = nil,
                            error: Error,
                            request: URLRequest,
                            response: HTTPURLResponse?,
                            responseData: Data?) {
        guard let log = self.log else { return }
        let separator = "-----------------------------------------------------------------------"
        var text = "\n\n\(separator)\nNETWORK ERROR"
        if let attempting = attempting {
            text = "\(text)\nattempting: \(attempting)"
        }
        text = "\(text)\nDescription: \(error.localizedDescription)"
        text = "\(text)\nRequest method: \(request.httpMethod?.uppercased() ?? "No VERB")"
        text = "\(text)\nOn \(request.url?.absoluteString ?? "No URL")"
        let code = response?.statusCode ?? (error as NSError).code
        text = "\(text)\nCode: \(code)"
        if let requestData = request.httpBody {
            text = "\(text)\n\nRequest data:\n\(String(data: requestData, encoding: .utf8)!)"
        }
        if let responseData = responseData {
            text = "\(text)\n\nResponse data:\n\(String(data: responseData, encoding: .utf8)!)"
        }
        if request.allHTTPHeaderFields?.isEmpty == false {
            text = "\n\(text)\nRequest Headers:"
            request.allHTTPHeaderFields?.forEach({ (key, value) in
                text = "\(text)\n\(key):  \(value)"
            })
        }
        text = "\(text)\n\(separator)\n\n"
        log.error(message: text, functionName: #function, fileName: #file, lineNumber: #line)
        let taskError = taskFailureToError(code: code, text: text)
        if ![NSURLErrorNotConnectedToInternet,NSURLErrorNetworkConnectionLost].contains(code) {
            log.notifyError(taskError, functionName: #function, fileName: #file, lineNumber: #line)
        }
    }
    
    func taskFailureToError(code: Int, text: String) -> NSError {
        return NSError(domain: "iOS Workfinder Networking", code: code, userInfo: ["reason": text])
    }
    
    func logDataTaskSuccess(request: URLRequest,
                            response: HTTPURLResponse,
                            responseData: Data) {
        guard let log = self.log else { return }
        let separator = "-----------------------------------------------------------------------"
        var text = "\n\n\(separator)\nNETWORK SUCCESS"
        text = "\(text)\nRequest method: \(request.httpMethod!.uppercased())"
        text = "\(text)\nOn \(request.url!.absoluteString)"
        let code = response.statusCode
        text = "\(text)\nCode: \(code)"
        if let requestData = request.httpBody {
            if let dataAsString = String(data: requestData, encoding: .utf8) {
                text = "\(text)\n\nRequest data:\n\(dataAsString)"
            } else {
                text = "\(text)\n\nRequest data: \(requestData.count) bytes"
            }
        }
        text = "\(text)\n\nResponse data:\n\(String(data: responseData, encoding: .utf8)!)"
        if request.allHTTPHeaderFields?.isEmpty == false {
            text = "\n\(text)\nRequest Headers:"
            request.allHTTPHeaderFields?.forEach({ (key, value) in
                text = "\(text)\n\(key):  \(value)"
            })
        }
        text = "\(text)\n\(separator)\n\n"
        log.debug(text, functionName: #function, fileName: #file, lineNumber: #line)
    }
    
}
