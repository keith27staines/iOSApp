import Foundation
import WorkfinderCommon
import WorkfinderNetworking

public class F4SMessageActionService : F4SDataTaskService, F4SMessageActionServiceProtocol {
    
    public let threadUuid: String
    
    public init(threadUuid: F4SUUID, configuration: NetworkConfig) {
        self.threadUuid = threadUuid
        let apiName = "messaging/\(threadUuid)/user_action"
        super.init(baseURLString: configuration.workfinderApiV2,
                   apiName: apiName,
                   configuration: configuration)
    }
    
    public func getMessageAction(completion: @escaping (F4SNetworkResult<F4SAction?>) -> ()) {
        beginGetRequest(attempting: "Get action for thread", completion: completion)
    }
    
}

