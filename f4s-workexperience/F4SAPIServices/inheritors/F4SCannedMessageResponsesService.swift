import Foundation

// MARK:- F4SCannedMessageResponsesService
public protocol F4SCannedMessageResponsesServiceProtocol {
    
    var apiName: String { get }
    var threadUuid: String { get }
    func getPermittedResponses(completion: @escaping (F4SNetworkResult<F4SCannedResponses>) -> ())
}

public class F4SCannedMessageResponsesService : F4SDataTaskService {
    
    public let threadUuid: String
    
    public init(threadUuid: F4SUUID) {
        self.threadUuid = threadUuid
        let apiName = "messaging/\(threadUuid)/possible_responses"
        super.init(baseURLString: NetworkConfig.workfinderApiV2, apiName: apiName)
    }
}

extension F4SCannedMessageResponsesService : F4SCannedMessageResponsesServiceProtocol {
    
    public func getPermittedResponses(completion: @escaping (F4SNetworkResult<F4SCannedResponses>) -> ()) {
        beginGetRequest(attempting: "Get message options for thread", completion: completion)
    }
}
