import Foundation
import WorkfinderCommon
import WorkfinderNetworking

public protocol F4SMessageServiceProtocol {
    var apiName: String { get }
    var threadUuid: String { get }
    func getMessages(completion: @escaping (F4SNetworkResult<F4SMessagesList>) -> ())
    func sendMessage(responseUuid: F4SUUID, completion: @escaping (F4SNetworkResult<F4SMessagesList>) -> Void)
}

public class F4SMessageService : F4SDataTaskService {
    
    public let threadUuid: String
    
    public init(threadUuid: F4SUUID) {
        self.threadUuid = threadUuid
        let apiName = "messaging/\(threadUuid)"
        super.init(baseURLString: NetworkConfig.workfinderApiV2, apiName: apiName)
    }
}

extension F4SMessageService : F4SMessageServiceProtocol {
    
    public func getMessages(completion: @escaping (F4SNetworkResult<F4SMessagesList>) -> ()) {
        beginGetRequest(attempting: "Get messages for thread", completion: completion)
    }
    
    public func sendMessage(responseUuid: F4SUUID, completion: @escaping (F4SNetworkResult<F4SMessagesList>) -> Void) {
        let attempting = "Send message to thread"
        let sendDictionary = ["response_uuid": responseUuid]
        beginSendRequest(verb: .put, objectToSend: sendDictionary, attempting: attempting, completion: { [weak self] result in
            self?.processResult(result, attempting: attempting, completion: completion)
        })
    }
}
