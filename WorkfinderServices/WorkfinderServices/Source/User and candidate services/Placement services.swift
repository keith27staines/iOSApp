import Foundation
import WorkfinderCommon

public protocol PostPlacementServiceProtocol {
    func postPlacement(draftPlacement: Placement, completion: @escaping ((Result<Placement, Error>) -> Void))
}

public protocol GetPlacementServiceProtocol {
    
}

public class PostPlacementService: WorkfinderService, PostPlacementServiceProtocol {
    
    public func postPlacement(draftPlacement: Placement, completion: @escaping ((Result<Placement, Error>) -> Void)) {
        do {
            let relativePath = "placements/"
            let request = try buildRequest(relativePath: relativePath, verb: .post, body: draftPlacement)
            performTask(with: request, completion: completion, attempting: #function)
        } catch {
            completion(Result<Placement,Error>.failure(error))
        }
    }
}

public class GetPlacementService: WorkfinderService, GetPlacementServiceProtocol {
    
}
