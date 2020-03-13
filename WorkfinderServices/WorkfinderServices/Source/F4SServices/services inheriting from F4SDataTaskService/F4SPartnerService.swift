import WorkfinderCommon

public class F4SPartnerService : F4SDataTaskService, F4SPartnerServiceProtocol {
    public init(configuration: NetworkConfig) {
        super.init(baseURLString: configuration.workfinderApiV2, apiName: "partner", configuration: configuration)
    }

    public func getPartners(completion: @escaping (F4SNetworkResult<[F4SPartner]>) -> ()) {
        //beginGetRequest(attempting: "Get partners", completion: completion)
        completion(F4SNetworkResult.success([]))
    }
}
