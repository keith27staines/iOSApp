import Foundation
import WorkfinderCommon

public class F4SCompanyDocumentService: F4SDataTaskService, F4SCompanyDocumentServiceProtocol {

    public init(configuration: NetworkConfig) {
        let apiName = "company"
        super.init(baseURLString: configuration.workfinderApiV2,
                   apiName: apiName,
                   configuration: configuration)
    }
    
    public func requestDocuments(companyUuid: F4SUUID, documents: F4SCompanyDocuments, completion: @escaping ((F4SNetworkResult<F4SJSONBoolValue>) -> ())) {
        let attempting = "Request documents"
        relativeUrlString = "companyUuid/documents"
        beginSendRequest(verb: .post, objectToSend: documents, attempting: attempting) {
            dataResult in
            switch dataResult {
            case .error(let error):
                completion(F4SNetworkResult.error(error))
            case .success(_):
                completion(F4SNetworkResult.success(F4SJSONBoolValue(value: true)))
            }
        }
    }
    
    public func getDocuments(companyUuid: F4SUUID, completion: @escaping (F4SNetworkResult<F4SGetCompanyDocuments>)->()) {
        let attempting = "Get company documents"
        relativeUrlString = "\(companyUuid)/documents"
        beginGetRequest(attempting: attempting, completion: completion)
    }
    
}
