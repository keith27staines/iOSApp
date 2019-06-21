//
//  Logger.swift
//  WorkfinderNetworking
//
//  Created by Keith Dev on 21/06/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation
import WorkfinderCommon

var logger: Logger!

class Logger {
    
    let log: F4SAnalyticsAndDebugging?
    
    init(log: F4SAnalyticsAndDebugging?) {
        self.log = log
    }
    
    func logDataTaskFailure(error: Error,
                            request: URLRequest,
                            response: HTTPURLResponse?,
                            responseData: Data?,
                            functionName: StaticString = #function,
                            fileName: StaticString = #file,
                            lineNumber: Int = #line) {
        guard let log = self.log else { return }
        let separator = "-----------------------------------------------------------------------"
        var text = "\n\n\(separator)\nNETWORK ERROR"
        text = "\(text)\nDescription: \(error.localizedDescription)"
        text = "\(text)\nRequest method: \(request.httpMethod?.uppercased() ?? "No VERB")"
        text = "\(text)\nOn \(request.url?.absoluteString ?? "No URL")"
        let code = response?.statusCode ?? (error as NSError).code
        text = "\(text)\nCode: \(code)"
        if let requestData = request.httpBody {
            text = "\(text)\n\nRequest data:\n\(String(data: requestData, encoding: .utf8)!))"
        }
        if let responseData = responseData {
            text = "\(text)\n\nResponse data:\n\(String(data: responseData, encoding: .utf8)!))"
        }
        if request.allHTTPHeaderFields?.isEmpty == false {
            text = "\n\(text)\nRequest Headers:"
            request.allHTTPHeaderFields?.forEach({ (key, value) in
                text = "\(text)\n\(key):  \(value)"
            })
        }
        text = "\(text)\n\(separator)\n\n"
        log.error(message: text, functionName: #function, fileName: #file, lineNumber: #line)
    }
}
