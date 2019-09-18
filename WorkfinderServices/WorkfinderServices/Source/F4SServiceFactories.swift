import Foundation
import WorkfinderCommon

// MARK:- Factory implementations

public class F4SDocumentUploaderFactory: F4SDocumentUploaderFactoryProtocol {

    let configuration: NetworkConfig
    
    public init(configuration: NetworkConfig) {
        self.configuration = configuration
    }
    
    public func makeDocumentUploader(document: F4SDocument, placementuuid: F4SUUID) -> F4SDocumentUploaderProtocol? {
        return F4SDocumentUploader(document: document,
                                   placementUuid: placementuuid,
                                   configuration: configuration)
    }
}



public class F4SMessageServiceFactory : F4SMessageServiceFactoryProtocol {
    let configuration: NetworkConfig
    public init(configuration: NetworkConfig) {
        self.configuration = configuration
    }
    public func makeMessageService(threadUuid: F4SUUID) -> F4SMessageServiceProtocol {
        return F4SMessageService(threadUuid: threadUuid, configuration: configuration)
    }
}

public class F4SCannedMessageResponsesServiceFactory : F4SCannedMessageResponsesServiceFactoryProtocol {
    let configuration: NetworkConfig
    public init(configuration: NetworkConfig) {
        self.configuration = configuration
    }
    
    public func makeCannedMessageResponsesService(threadUuid: F4SUUID) -> F4SCannedMessageResponsesServiceProtocol {
        return F4SCannedMessageResponsesService(threadUuid: threadUuid, configuration: configuration)
    }
}

public class F4SMessageActionServiceFactory : F4SMessageActionServiceFactoryProtocol {
    let configuration: NetworkConfig
    public init(configuration: NetworkConfig) {
        self.configuration = configuration
    }
    
    public func makeMessageActionService(threadUuid: F4SUUID) -> F4SMessageActionServiceProtocol {
        return F4SMessageActionService(threadUuid: threadUuid, configuration: configuration)
    }
}
