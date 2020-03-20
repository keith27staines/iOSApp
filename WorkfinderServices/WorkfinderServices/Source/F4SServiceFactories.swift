import Foundation
import WorkfinderCommon

public class EmailVerificationServiceFactory: EmailVerificationServiceFactoryProtocol {
    
    let configuration: NetworkConfig
    
    public init(configuration: NetworkConfig) {
        self.configuration = configuration
    }
    
    public func makeEmailVerificationService() -> EmailVerificationServiceProtocol {
        return EmailVerificationService(configuration: configuration)
    }
}

public class F4SPlacementDocumentsServiceFactory: F4SPlacementDocumentsServiceFactoryProtocol {
    public func makePlacementDocumentsService(placementUuid: F4SUUID) -> F4SPlacementDocumentsServiceProtocol {
        return F4SPlacementDocumentsService()
    }
    
    public init(){
    }
}

public class F4SPlacementDocumentsService: F4SPlacementDocumentsServiceProtocol {
    public func getDocuments(completion: @escaping (F4SNetworkResult<F4SGetDocumentJson>) -> ()) {
        
    }
    
    public func putDocuments(documents: F4SPutDocumentsJson, completion: @escaping ((F4SNetworkResult<F4SJSONBoolValue>) -> Void)) {
        
    }
}

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
