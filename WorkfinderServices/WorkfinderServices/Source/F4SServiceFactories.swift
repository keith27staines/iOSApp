import Foundation
import WorkfinderCommon

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
