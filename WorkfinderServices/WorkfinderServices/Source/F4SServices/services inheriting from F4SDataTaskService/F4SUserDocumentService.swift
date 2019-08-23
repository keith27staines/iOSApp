import Foundation
import WorkfinderCommon
import WorkfinderNetworking

public protocol F4SUserDocumentsServiceProtocol {
    func getDocuments(completion: @escaping (F4SNetworkResult<F4SGetDocumentJson>) -> ())
}

public class F4SUserDocumentsService : F4SDataTaskService, F4SUserDocumentsServiceProtocol {
    
    public init() {
        let apiName = "documents"
        super.init(baseURLString: NetworkConfig.workfinderApiV2, apiName: apiName)
    }
    
    public func getDocuments(completion: @escaping (F4SNetworkResult<F4SGetDocumentJson>) -> ()) {
        beginGetRequest(attempting: "Get document for the current user", completion: completion)
    }
}
