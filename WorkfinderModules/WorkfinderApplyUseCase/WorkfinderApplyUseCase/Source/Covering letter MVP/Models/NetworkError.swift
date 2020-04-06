
import Foundation

public enum NetworkError: Error {
    case clientError(Error)
    case httpError(HTTPURLResponse)
    case responseBodyEmpty(HTTPURLResponse)
    case deserialization(Error)
}
