import Foundation
import WorkfinderCommon
import WorkfinderNetworking

public protocol F4SPlacementDocumentServiceProtocol {
    var apiName: String { get }
    var placementUuid: String { get }
    func getDocuments(completion: @escaping (F4SNetworkResult<F4SGetDocumentJson>) -> ())
    func putDocuments(documents: F4SPutDocumentsJson, completion: @escaping ((F4SNetworkResult<F4SJSONBoolValue>) -> Void ))
}

public class F4SPlacementDocumentsService : F4SDataTaskService {
    public let placementUuid: String
    
    public init(placementUuid: F4SUUID) {
        self.placementUuid = placementUuid
        let apiName = "placement/\(placementUuid)/documents"
        super.init(baseURLString: NetworkConfig.workfinderApiV2, apiName: apiName)
    }
}

// MARK:- F4SDocumentServiceProtocol conformance
extension F4SPlacementDocumentsService : F4SPlacementDocumentServiceProtocol {
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

