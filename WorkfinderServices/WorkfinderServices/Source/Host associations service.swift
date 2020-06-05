
import Foundation
import WorkfinderCommon

public class HostLocationAssociationsService: WorkfinderService, HostLocationAssociationsServiceProtocol {
    
    let relativePath = "associations/"
    
    public func fetchAssociation(
        uuid: F4SUUID,
        completion:  @escaping((Result<HostWorkplaceAssociationJson,Error>) -> Void)) {
        do {
            let path = "\(relativePath)\(uuid)"
            let request = try buildRequest(relativePath: path, queryItems: nil, verb: .get)
            performTask(with: request, completion: completion,
            attempting: #function)
        } catch {
            completion(Result<HostWorkplaceAssociationJson,Error>.failure(error))
        }
    }
    
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
            relativePath: relativePath,
            queryItems: queryItems,
            verb: .get)
    }
}
