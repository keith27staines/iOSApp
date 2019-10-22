import Foundation
import WorkfinderCommon

public class F4SPlacementApplicationService : F4SDataTaskService, F4SPlacementApplicationServiceProtocol {
    
    public init(configuration: NetworkConfig) {
        let apiName = "placement"
        super.init(baseURLString: configuration.workfinderApiV2,
                   apiName: apiName,
                   configuration: configuration)
    }
    
    public func getPlacement(uuid: F4SUUID, completion: @escaping (F4SNetworkResult<F4SPlacementJson>) -> ()) {
        let attempting = "Get placement"
        relativeUrlString = uuid
        beginGetRequest(attempting: attempting, completion: completion)
    }
    
    public func apply(with json: F4SCreatePlacementJson,
        completion: @escaping (F4SNetworkResult<F4SPlacementJson>) -> Void) {
        let attempting = "Apply"
        relativeUrlString = nil
        beginSendRequest(verb: .post, objectToSend: json, attempting: "Apply") { [weak self] (result) in
            self?.processResult(result, attempting: attempting, completion: completion)
        }
    }
    
    public func update(uuid: F4SUUID, with json: F4SPlacementJson, completion: @escaping (F4SNetworkResult<F4SPlacementJson>) -> Void) {
        let attempting = "Update placement application"
        relativeUrlString = uuid
        beginSendRequest(verb: .patch, objectToSend: json, attempting: "Apply") { [weak self] (result) in
            self?.processResult(result, attempting: attempting, completion: completion)
        }
    }
}
