import Foundation
import WorkfinderCommon
import WorkfinderNetworking

/// Defines the interface for factories of objects conforming to F4SPlacementApplicationServiceProtocol
public protocol F4SPlacementApplicationServiceFactoryProtocol {
    /// Creates and returns an object conforming to F4SPlacementApplicationServiceFactoryProtocol
    func makePlacementService() -> F4SPlacementApplicationServiceProtocol
}

public protocol F4SPlacementApplicationServiceProtocol {
    
    func apply(with json: F4SCreatePlacementJson,
               completion: @escaping (F4SNetworkResult<F4SPlacementJson>) -> Void)
    
    func update(uuid: F4SUUID, with json: F4SPlacementJson, completion: @escaping (F4SNetworkResult<F4SPlacementJson>) -> Void)
}

public class F4SPlacementApplicationService : F4SDataTaskService, F4SPlacementApplicationServiceProtocol{
    
    public init() {
        let apiName = "placement"
        super.init(baseURLString: NetworkConfig.workfinderApiV2, apiName: apiName)
        
    }
    
    public func apply(with json: F4SCreatePlacementJson,
        completion: @escaping (F4SNetworkResult<F4SPlacementJson>) -> Void) {
        let attempting = "Apply"
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
