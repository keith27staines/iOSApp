import WorkfinderCommon
import WorkfinderNetworking

public class F4SCompanyService: F4SDataTaskService, F4SCompanyServiceProtocol {

    public init(configuration: NetworkConfig) {
        let apiName = "company"
        super.init(baseURLString: configuration.workfinderApiV2,
                   apiName: apiName,
                   configuration: configuration)
    }

    public func getCompany(uuid: F4SUUID, completion: @escaping
        (F4SNetworkResult<F4SCompanyJson>) -> ()) {
        relativeUrlString = uuid
        beginGetRequest(attempting: "Get company detail", completion: completion)
    }
}












