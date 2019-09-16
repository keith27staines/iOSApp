import Foundation
import WorkfinderCommon

public class F4SCompanyFavouritingService : F4SDataTaskService, CompanyFavouritingServiceProtocol {

    public init(configuration: NetworkConfig) {
        super.init(baseURLString: configuration.workfinderApiV2, apiName: "favourite", configuration: configuration)
    }
    
    public func favourite(companyUuid: F4SUUID, completion: @escaping (F4SNetworkResult<F4SShortlistJson>) -> ()) {
        let params = ["company_uuid": companyUuid]
        let attempting = "Create shortist item for company"
        relativeUrlString = nil
        super.beginSendRequest(verb: .post, objectToSend: params, attempting: attempting) { [weak self] (result) in
            self?.processResult(result, attempting: attempting, completion: completion)
        }
    }
    
    public func unfavourite(shortlistUuid: String, completion: @escaping (F4SNetworkResult<F4SUUID>) -> ()) {
        let attempting = "Unfavourite"
        relativeUrlString = shortlistUuid
        super.beginDelete(attempting: attempting) { (result) in
            switch result {
            case .error(let error):
                completion(F4SNetworkResult.error(error))
            case .success(_):
                completion(F4SNetworkResult.success(shortlistUuid))
            }
        }
    }
}
