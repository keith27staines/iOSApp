
import Foundation
import WorkfinderCommon

public class AssociationsService: WorkfinderService, AssociationsServiceProtocol {
    
    let relativePath = "associations/"
    
    public func fetchAssociation(
        uuid: F4SUUID,
        completion:  @escaping((Result<AssociationJson,Error>) -> Void)) {
        do {
            let path = "\(relativePath)\(uuid)"
            let request = try buildRequest(relativePath: path, queryItems: nil, verb: .get)
            performTask(with: request, completion: completion, attempting: #function)
        } catch {
            completion(Result<AssociationJson,Error>.failure(error))
        }
    }
    
    public func fetchAssociations(
        queryItems: [URLQueryItem],
        completion:  @escaping((Result<HostAssociationListJson,Error>) -> Void)
    ) {
        
        do {
            let request = try buildFetchAssociationsRequest(location: nil, queryItems: queryItems)
            performTask(
                with: request,
                completion: completion, attempting: #function)
        } catch {
            completion(Result<HostAssociationListJson,Error>.failure(error))
        }
    }
    
    public func fetchAssociations(
        for locationUuid: F4SUUID,
        completion:  @escaping((Result<HostAssociationListJson,Error>) -> Void)) {
        
        do {
            let request = try buildFetchAssociationsRequest(location: locationUuid)
            performTask(
                with: request,
                completion: completion, attempting: #function)
        } catch {
            completion(Result<HostAssociationListJson,Error>.failure(error))
        }
    }
    
    func buildFetchAssociationsRequest(location: F4SUUID?, queryItems: [URLQueryItem] = []) throws -> URLRequest {
        var qItems = queryItems
        qItems.append(URLQueryItem(name: "expand-host", value: "1"))
        if let location = location {
            qItems.append(URLQueryItem(name: "location__uuid", value: location))
        }
        return try buildRequest(
            relativePath: relativePath,
            queryItems: qItems,
            verb: .get)
    }
}
