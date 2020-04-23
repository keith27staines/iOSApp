import Foundation

/// Defines the methods required to log detailed information about network calls
public protocol NetworkCallLoggerProtocol {
    /// Logs failures and writes the failure details to an external notification service
    func logDataTaskFailure(attempting: String?,
                            error: Error,
                            request: URLRequest,
                            response: HTTPURLResponse?,
                            responseData: Data?)
    
    func logDeserializationError<T:Decodable>(
        to type: T.Type,
        from data:
        Data, error: NSError)
    
    /// Logs successes locally
    func logDataTaskSuccess(request: URLRequest,
                            response: HTTPURLResponse,
                            responseData: Data)
}
