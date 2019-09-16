import Foundation
import WorkfinderCommon
import WorkfinderNetworking

public class F4SUserDocumentsService : F4SDataTaskService, F4SUserDocumentsServiceProtocol {
    
    public init(configuration: NetworkConfig) {
        let apiName = "documents"
        super.init(baseURLString: configuration.workfinderApiV2, apiName: apiName, configuration: configuration)
    }
    
    public func getDocuments(completion: @escaping (F4SNetworkResult<F4SGetDocumentJson>) -> ()) {
        beginGetRequest(attempting: "Get document for the current user", completion: completion)
    }
}
