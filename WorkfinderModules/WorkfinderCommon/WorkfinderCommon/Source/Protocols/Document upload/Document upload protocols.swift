import Foundation

public enum DocumentUploadState {
    case preparing
    case uploading(fraction: Float)
    case completed
    case cancelled
    case failed(error: Error)
}

public typealias F4SVersionValidity = Bool

public protocol F4SDocumentUploaderFactoryProtocol {
    func makeDocumentUploader(document: F4SDocument, placementuuid: F4SUUID) -> F4SDocumentUploaderProtocol?
}

public protocol F4SDocumentUploaderDelegate : AnyObject {
    func documentUploader(_ uploader: F4SDocumentUploaderProtocol, didChangeState state: DocumentUploadState)
}

public protocol F4SDocumentUploaderProtocol : AnyObject {
    var delegate: F4SDocumentUploaderDelegate? { get set }
    var state: DocumentUploadState { get }
    func cancel()
    func resume()
}

