import Foundation
import WorkfinderCommon

public class MockF4SPlacementApplicationService : F4SPlacementApplicationServiceProtocol {
    
    public var resultForCreate: F4SNetworkResult<F4SPlacementJson>?
    public var resultForPatch: F4SNetworkResult<F4SPlacementJson>?
    public var createCount: Int = 0
    public var patchCount: Int = 0
    
    public init(createResult: F4SNetworkResult<F4SPlacementJson>) {
        self.resultForCreate = createResult
    }
    
    public init(patchResult: F4SNetworkResult<F4SPlacementJson>) {
        self.resultForPatch = patchResult
    }
    
    public func apply(with json: F4SCreatePlacementJson, completion: @escaping (F4SNetworkResult<F4SPlacementJson>) -> Void) {
        createCount += 1
        completion(resultForCreate!)
    }
    
    public func update(uuid: F4SUUID, with json: F4SPlacementJson, completion: @escaping (F4SNetworkResult<F4SPlacementJson>) -> Void) {
        patchCount += 1
        completion(resultForPatch!)
    }
}
