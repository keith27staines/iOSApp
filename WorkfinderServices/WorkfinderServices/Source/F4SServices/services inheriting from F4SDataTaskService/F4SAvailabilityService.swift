import Foundation
import WorkfinderCommon

public class F4SAvailabilityService : F4SDataTaskService, F4SAvailabilityServiceProtocol {
    
    public let placementUuid: String
    
    public init(placementUuid: F4SUUID, configuration: NetworkConfig) {
        self.placementUuid = placementUuid
        let apiName = "placement/\(placementUuid)"
        super.init(baseURLString: configuration.workfinderApiV2, apiName: apiName, configuration: configuration)
    }

    public func getAvailabilityForPlacement(completion: @escaping (F4SNetworkResult<[F4SAvailabilityPeriodJson]>) -> ()) {
        beginGetRequest(attempting: "Get availability periods for this placement", completion: completion)
    }
    
    public func patchAvailabilityForPlacement(availabilityPeriods: F4SAvailabilityPeriodsJson, completion: @escaping ((F4SNetworkDataResult) -> Void )) {
        beginSendRequest(verb: .patch, objectToSend: availabilityPeriods, attempting: "Patch availability periods for this placement", completion: completion)
    }
}
