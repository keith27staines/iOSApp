import Foundation
import WorkfinderCommon

public struct Placement: Codable {
    public var uuid: F4SUUID?
    public var candidateUuid: F4SUUID?
    public var associationUuid: F4SUUID?
    public var coverLetterString: F4SUUID?
    public var createdDatetimeString: String?
    public var status: String?
    
    public init() {
        
    }
    
    private enum CodingKeys: String, CodingKey {
        case uuid
        case candidateUuid = "candidate"
        case associationUuid = "association"
        case coverLetterString = "cover_letter"
        case createdDatetimeString = "created_at"
        case status
    }
}

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
