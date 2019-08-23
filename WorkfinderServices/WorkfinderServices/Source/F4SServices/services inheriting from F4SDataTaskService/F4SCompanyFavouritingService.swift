import Foundation
import WorkfinderCommon
import WorkfinderNetworking

public struct F4SShortlistJson : Codable {
    public var uuid: F4SUUID?
    public var companyUuid: F4SUUID?
    public var errors: F4SServerErrors?
    
    enum CodingKeys : String, CodingKey {
        case uuid
        case companyUuid = "company_uuid"
        case errors
    }
}

public struct F4SServerErrors : Codable {
    public var errors: F4SJSONValue
}

public protocol CompanyFavouritingServiceProtocol {
    var apiName: String { get }
    func favourite(companyUuid: F4SUUID, completion: @escaping (F4SNetworkResult<F4SShortlistJson>) -> Void)
    func unfavourite(shortlistUuid: String, completion: @escaping (F4SNetworkResult<F4SUUID>) -> Void)
}

public class F4SCompanyFavouritingService : F4SDataTaskService, CompanyFavouritingServiceProtocol {

    public init() {
        super.init(baseURLString: NetworkConfig.workfinderApiV2, apiName: "favourite")
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
