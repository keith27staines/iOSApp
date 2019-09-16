import Foundation
import WorkfinderCommon
import WorkfinderNetworking

public class F4SCannedMessageResponsesService : F4SDataTaskService, F4SCannedMessageResponsesServiceProtocol {
    
    public let threadUuid: String
    
    public init(threadUuid: F4SUUID, configuration: NetworkConfig) {
        self.threadUuid = threadUuid
        let apiName = "messaging/\(threadUuid)/possible_responses"
        super.init(baseURLString: configuration.workfinderApiV2,
                   apiName: apiName,
                   configuration: configuration)
    }
    
    public func getPermittedResponses(completion: @escaping (F4SNetworkResult<F4SCannedResponses>) -> ()) {
        beginGetRequest(attempting: "Get message options for thread", completion: completion)
    }
}
