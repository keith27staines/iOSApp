import Foundation
import WorkfinderCommon
import WorkfinderNetworking

public class F4SContentService : F4SDataTaskService, F4SContentServiceProtocol {
    public init(configuration: NetworkConfig) {
        super.init(baseURLString: configuration.workfinderApiV2, apiName: "content", configuration: configuration)
    }
    
    public func getContent(completion: @escaping (F4SNetworkResult<[F4SContentDescriptor]>) -> ()) {
        beginGetRequest(attempting: "Get content", completion: completion)
    }
}
