import Foundation
import WorkfinderCommon

public class F4SPlacementRepository : F4SPlacementRepositoryProtocol {
    
    public func save(placement: F4SPlacement) {
        PlacementDBOperations.sharedInstance.savePlacement(placement: placement)
    }
    
    public func load() -> [F4SPlacement] {
        return PlacementDBOperations.sharedInstance.getAllPlacements()
    }
    
}

public class F4SFavouritesRepository: F4SFavouritesRepositoryProtocol {
    public func loadFavourites() -> [Shortlist] {
        return ShortlistDBOperations.sharedInstance.getShortlistForCurrentUser()
    }
    
    public func removeFavourite(uuid: F4SUUID) {
        ShortlistDBOperations.sharedInstance.removeShortlistWithId(shortlistUuid: uuid)
    }
    
    public func addFavourite(_ item: Shortlist) {
        ShortlistDBOperations.sharedInstance.saveShortlist(shortlist: item)
    }
}

public class F4SCompanyRepository : F4SCompanyRepositoryProtocol {
    
    public func load(companyUuid: F4SUUID) -> Company? {
        return DatabaseOperations.sharedInstance.companyWithUUID(companyUuid)
    }
    
    public func load(companyUuids: [F4SUUID], completion: @escaping (([Company]) -> Void) ) {
        DatabaseOperations.sharedInstance.getCompanies(withUuid: companyUuids) { (companies) in
            completion(companies)
        }
    }
    
}
