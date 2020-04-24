
import Foundation
import WorkfinderCommon
import WorkfinderServices

public class HostLocationAssociationsService: WorkfinderService, HostLocationAssociationsServiceProtocol {
    
    public func fetchAssociations(
        for locationUuid: F4SUUID,
        completion:  @escaping((Result<HostLocationAssociationListJson,Error>) -> Void)) {
        
        do {
            let request = try buildFetchAssociationsRequest(location: locationUuid)
            performTask(
                with: request,
                completion: completion, attempting: #function)
        } catch {
            completion(Result<HostLocationAssociationListJson,Error>.failure(error))
        }
    }
    
    func buildFetchAssociationsRequest(location: F4SUUID) throws -> URLRequest {
        let queryItems = [
            URLQueryItem(name: "location__uuid", value: location),
            URLQueryItem(name: "expand-host", value: "1")
        ]
        return try buildRequest(
            relativePath: "associations/",
            queryItems: queryItems,
            verb: .get)
    }
}
