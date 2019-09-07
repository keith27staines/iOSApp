import Foundation
import WorkfinderCommon

public class F4SPlacementRespository : F4SPlacementRepositoryProtocol {
    
    public func save(placement: F4SPlacement) {
        PlacementDBOperations.sharedInstance.savePlacement(placement: placement)
    }
    
}

public class F4SCompanyRepository : F4SCompanyRepositoryProtocol {
    
    public func load(companyUuid: F4SUUID) -> Company? {
        return DatabaseOperations.sharedInstance.companyWithUUID(companyUuid)
    }
    
}
