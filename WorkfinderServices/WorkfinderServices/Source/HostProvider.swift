import WorkfinderCommon

public class HostsProvider: WorkfinderService, HostsProviderProtocol {
        
    public func fetchHosts(
        locationUuid: F4SUUID,
        completion: @escaping((Result<HostListJson,Error>) -> Void) ) {
        
        do {
            let request = try buildFetchHostsRequest(locationUuid: locationUuid)
            performTask(
                with: request,
                completion: completion,
                attempting: #function)
        } catch {
            completion(Result<HostListJson,Error>.failure(error))
        }
    }
    
    func buildFetchHostsRequest(locationUuid: F4SUUID) throws -> URLRequest {
        return try buildRequest(
            relativePath: "hosts/",
            queryItems: [URLQueryItem(name: "location", value: locationUuid)],
            verb: .get)
    }
}
