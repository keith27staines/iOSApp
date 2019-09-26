
import Foundation
import WorkfinderCommon

public class AllowedToApplyLogic : AllowedToApplyLogicProtocol {
    
    var placements: [F4STimelinePlacement] = []
    let placementService: F4SGetAllPlacementsServiceProtocol
    
    public init(service: F4SGetAllPlacementsServiceProtocol) {
        self.placementService = service
    }
    
    public var draftTimelinePlacement: F4STimelinePlacement?
    public var draftPlacement: F4SPlacement? {
        return (draftTimelinePlacement != nil) ? F4SPlacement(timelinePlacement: draftTimelinePlacement!) : nil
    }
    
    public func checkUserCanApply(user: F4SUUID?,
                                  to company: F4SUUID,
                                  givenExistingPlacements existing: [F4STimelinePlacement],
                                  completion: @escaping (F4SNetworkResult<Bool>) -> Void) {
        DispatchQueue.main.async {
            self.placements = existing
            guard let match = existing.first(where: { (existing) -> Bool in
                existing.companyUuid?.dehyphenated == company.dehyphenated
            }) else {
                // No matching placement so the user is free to apply
                let result = F4SNetworkResult.success(true)
                completion(result)
                return
            }
            guard let workflowState = match.workflowState else {
                // The placement is in an unknown state so we can't allow the
                // user to resume it
                let result = F4SNetworkResult.success(false)
                completion(result)
                return
            }
            self.draftTimelinePlacement = (workflowState == .draft) ? match : nil
            let result = F4SNetworkResult.success(workflowState == F4SPlacementState.draft)
            completion(result)

        }
    }
    
    public func checkUserCanApply(user: F4SUUID?,
                                  to company: F4SUUID,
                                  completion: @escaping (F4SNetworkResult<Bool>) -> Void) {
        placementService.getAllPlacementsForUser { [weak self] (result) in
            guard let strongSelf = self else { return }
            switch result {
            case .error(_):
                break
            case .success(let placements):
                strongSelf.checkUserCanApply(user: user,
                                             to: company,
                                             givenExistingPlacements: placements,
                                             completion: completion)
            }
        }
        
    }
    
}