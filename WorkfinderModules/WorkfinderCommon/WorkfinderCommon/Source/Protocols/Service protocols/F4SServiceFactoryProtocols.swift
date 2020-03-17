

public protocol F4SDocumentUploaderFactoryProtocol {
    func makeDocumentUploader(document: F4SDocument, placementuuid: F4SUUID) -> F4SDocumentUploaderProtocol?
}



