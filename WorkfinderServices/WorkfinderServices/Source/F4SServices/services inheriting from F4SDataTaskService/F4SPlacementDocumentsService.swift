import Foundation
import WorkfinderCommon

public class F4SPlacementDocumentsService : F4SDataTaskService, F4SPlacementDocumentServiceProtocol {
    public let placementUuid: String
    
    public init(placementUuid: F4SUUID, configuration: NetworkConfig) {
        self.placementUuid = placementUuid
        let apiName = "placement/\(placementUuid)/documents"
        super.init(baseURLString: configuration.workfinderApiV2,
                   apiName: apiName,
                   configuration: configuration)
    }
}

// MARK:- F4SDocumentServiceProtocol conformance
extension F4SPlacementDocumentsService {
    public func getDocuments(completion: @escaping (F4SNetworkResult<F4SGetDocumentJson>) -> ()) {
        beginGetRequest(attempting: "Get supporting document urls for this placement", completion: completion)
    }
    
    public func putDocuments(documents: F4SPutDocumentsJson, completion: @escaping ((F4SNetworkResult<F4SJSONBoolValue>) -> Void )) {
        super.beginSendRequest(verb: .put, objectToSend: documents, attempting: "Upload supporting document urls for this placement") { dataResult in
            switch dataResult {
            case .error(_):
                completion(F4SNetworkResult.error(F4SNetworkError(localizedDescription: "Failed to request documents", attempting: "Requesting documents", retry: true)))
            case .success(_):
                completion(F4SNetworkResult.success(F4SJSONBoolValue()))
            }
        }
    }
}

