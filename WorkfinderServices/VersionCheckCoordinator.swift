
import Foundation
import WorkfinderCommon

public class VersionCheckingService: VersionCheckingServiceProtocol {
    
    public init() {
        
    }
    
    public func getIsVersionValid(version: String, completion: @escaping (F4SNetworkResult<F4SVersionValidity>) -> ()) {
        DispatchQueue.main.async {
            completion(F4SNetworkResult.success(true))
        }
    }
}
