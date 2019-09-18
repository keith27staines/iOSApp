
import Foundation
import WorkfinderCommon
import WorkfinderServices

// MARK:- F4SWorkfinderVersioningServiceProtocol conformance
extension F4SWorkfinderVersioningService  {
    public static var releaseVersionNumber: String? {
        let infoDictionary = Bundle.main.infoDictionary
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    public static var buildVersionNumber: String? {
        let infoDictionary = Bundle.main.infoDictionary
        return infoDictionary?["CFBundleVersion"] as? String
    }
    
    public func getIsVersionValid(completion: @escaping (F4SNetworkResult<F4SVersionValidity>) -> ()) {
        guard let version = F4SWorkfinderVersioningService.releaseVersionNumber else {
            completion(F4SNetworkResult.success(true))
            return
        }
        getIsVersionValid(version: version, completion: completion)
    }
}


