import Foundation
import WorkfinderCommon
import WorkfinderNetworking

public protocol F4SPlacementApplicationServiceProtocol {
    
    func apply(with json: WEXCreatePlacementJson,
               completion: @escaping (F4SNetworkResult<WEXPlacementJson>) -> Void)
    
    func update(uuid: F4SUUID, with json: WEXPlacementJson, completion: @escaping (F4SNetworkResult<WEXPlacementJson>) -> Void)
}

public class F4SPlacementApplicationService : F4SDataTaskService, F4SPlacementApplicationServiceProtocol{
    
    public init() {
        let apiName = "placement"
        super.init(baseURLString: NetworkConfig.workfinderApiV2, apiName: apiName)
        
    }
    
    public func apply(with json: WEXCreatePlacementJson,
        completion: @escaping (F4SNetworkResult<WEXPlacementJson>) -> Void) {
        let attempting = "Apply"
        beginSendRequest(verb: .post, objectToSend: json, attempting: "Apply") { [weak self] (result) in
            self?.processResult(result, attempting: attempting, completion: completion)
        }
    }
    
    public func update(uuid: F4SUUID, with json: WEXPlacementJson, completion: @escaping (F4SNetworkResult<WEXPlacementJson>) -> Void) {
        let attempting = "Update placement application"
        relativeUrlString = uuid
        beginSendRequest(verb: .patch, objectToSend: json, attempting: "Apply") { [weak self] (result) in
            self?.processResult(result, attempting: attempting, completion: completion)
        }
    }
}
