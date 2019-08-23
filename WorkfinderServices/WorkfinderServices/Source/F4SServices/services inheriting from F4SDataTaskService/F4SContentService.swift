import Foundation
import WorkfinderCommon
import WorkfinderNetworking

public protocol F4SContentServiceProtocol {
    var apiName: String { get }
    func getContent(completion: @escaping (F4SNetworkResult<[F4SContentDescriptor]>) -> ())
}

public class F4SContentService : F4SDataTaskService {
    public init() {
        super.init(baseURLString: NetworkConfig.workfinderApiV2, apiName: "content")
    }
}

// MARK:- F4SContentServiceProtocol conformance
extension F4SContentService : F4SContentServiceProtocol {
    public func getContent(completion: @escaping (F4SNetworkResult<[F4SContentDescriptor]>) -> ()) {
        beginGetRequest(attempting: "Get content", completion: completion)
    }
}
