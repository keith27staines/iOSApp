
import WorkfinderCommon

public class PicklistProvider: WorkfinderService, PicklistProviderProtocol {
    
    public let picklistType: PicklistType
    
    public init(picklistType: PicklistType, networkConfig: NetworkConfig) {
        self.picklistType = picklistType
        super.init(networkConfig: networkConfig)
    }
    
    public func fetchPicklistItems(completion: @escaping ((Result<PicklistServerJson,Error>) -> Void)) {
        do {
            let request = try buildFetchPicklistRequest(picklistType: picklistType)
            performTask(with: request, completion: completion, attempting: #function)
        } catch {
            completion(Result<PicklistServerJson,Error>.failure(error))
        }
    }
    
    func buildFetchPicklistRequest(picklistType: PicklistType) throws -> URLRequest {
        return try buildRequest(
            relativePath: picklistType.endpoint,
            queryItems: nil,
            verb: .get)
    }
}

