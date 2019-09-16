import Foundation
import WorkfinderCommon

public class F4SCompanyDatabaseMetadataService : F4SDataTaskService, F4SCompanyDatabaseMetadataServiceProtocol {
    
    public init(configuration: NetworkConfig) {
        let apiName = "company/dump/full"
        super.init(baseURLString: configuration.workfinderApiV2,
                   apiName: apiName,
                   configuration: configuration)
    }

    public func getDatabaseMetadata(completion: @escaping (F4SNetworkResult<F4SCompanyDatabaseMetaData>) -> ()) {
        beginGetRequest(attempting: "Get company database metadata", completion: completion)
    }
}

