import Foundation
import WorkfinderCommon
import WorkfinderNetworking

// MARK:- F4SMessageActionService
public protocol F4SMessageActionServiceProtocol {
    var apiName: String { get }
    var threadUuid: String { get }
    func getMessageAction(completion: @escaping (F4SNetworkResult<F4SAction?>) -> ())
}

public class F4SMessageActionService : F4SDataTaskService {
    
    public let threadUuid: String
    
    public init(threadUuid: F4SUUID) {
        self.threadUuid = threadUuid
        let apiName = "messaging/\(threadUuid)/user_action"
        super.init(baseURLString: NetworkConfig.workfinderApiV2, apiName: apiName)
    }
}

// MARK:- F4SMessageActionServiceProtocol conformance
extension F4SMessageActionService : F4SMessageActionServiceProtocol {
    
    public func getMessageAction(completion: @escaping (F4SNetworkResult<F4SAction?>) -> ()) {
        beginGetRequest(attempting: "Get action for thread", completion: completion)
    }
    
}

