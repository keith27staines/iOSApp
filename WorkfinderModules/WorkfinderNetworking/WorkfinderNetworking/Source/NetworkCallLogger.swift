import Foundation
import WorkfinderCommon

/// The concrete implementation of NetworkCallLogger used in this app. The main
/// work done by this implementation is to transform the success or failure info
/// into a very complete yet easily readable form.
/// The implementation uses an instance of `F4SAnalyticsAndDebugging` to write
/// data
public class NetworkCallLogger : NetworkCallLoggerProtocol {
    
    let log: F4SAnalyticsAndDebugging
    
    public init(log: F4SAnalyticsAndDebugging) {
        self.log = log
    }
    
    public func logDeserializationError<T:Decodable>(to type: T.Type, from data: Data, error: NSError) {
        let separator = "-----------------------------------------------------------------------"
        var text = "\n\n\(separator)\nDESERIALIZATION ERROR"
        text = "\(text)\nDescription: Failed to deserialise to type \(type)"
        text = "\(text)\nwith error: \(error.debugDescription)"
        text = "\(text)\nfrom data: \(String(data: data, encoding: .utf8) ?? "not string encodable")"
        log.error(message: text, functionName: #function, fileName: #file, lineNumber: #line)
        log.notifyError(error, functionName: #function, fileName: #file, lineNumber: #line)
        assertionFailure()
    }
    
    public func logDataTaskFailure(attempting: String? = nil,
                            error: Error,
                            request: URLRequest,
                            response: HTTPURLResponse?,
                            responseData: Data?) {
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
    
    public func logDataTaskSuccess(request: URLRequest,
                            response: HTTPURLResponse,
                            responseData: Data) {
        let separator = "-----------------------------------------------------------------------"
        var text = "\n\n\(separator)\nNETWORK SUCCESS"
        text = "\(text)\nRequest method: \(request.httpMethod!.uppercased())"
        text = "\(text)\nOn \(request.url!.absoluteString)"
        let code = response.statusCode
        text = "\(text)\nCode: \(code)"
        if let requestData = request.httpBody {
            if let dataAsString = String(data: requestData, encoding: .utf8), !dataAsString.isEmpty {
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
