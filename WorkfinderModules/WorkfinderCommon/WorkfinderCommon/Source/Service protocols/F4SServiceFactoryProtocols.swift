
public protocol F4SPlacementApplicationServiceFactoryProtocol {
    func makePlacementService() -> F4SPlacementApplicationServiceProtocol
}

public protocol F4SDocumentUploaderFactoryProtocol {
    func makeDocumentUploader(document: F4SDocument, placementuuid: F4SUUID) -> F4SDocumentUploaderProtocol?
}

public protocol F4SMessageServiceFactoryProtocol {
    func makeMessageService(threadUuid: F4SUUID) -> F4SMessageServiceProtocol
}

public protocol F4SCannedMessageResponsesServiceFactoryProtocol {
    func makeCannedMessageResponsesService(threadUuid: F4SUUID) -> F4SCannedMessageResponsesServiceProtocol
}

public protocol F4SMessageActionServiceFactoryProtocol {
    func makeMessageActionService(threadUuid: F4SUUID) -> F4SMessageActionServiceProtocol
}


