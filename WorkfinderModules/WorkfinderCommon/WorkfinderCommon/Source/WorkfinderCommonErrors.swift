import Foundation

/// Errors that may be thrown by WorkfinderCommon
public enum WorkfinderCommonErrors: Error {
    case initialisedWithInvalidApiURLString(String)
}

/// Errors that may be thrown during a network request
public enum NetworkError: Error {
    case clientError(Error)
    case httpError(HTTPURLResponse)
    case responseBodyEmpty(HTTPURLResponse)
    case deserialization(Error)
}
