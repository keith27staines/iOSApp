import WorkfinderCommon

public protocol LocationServiceProtocol {
    func fetchLocation(locationUuid: F4SUUID, completion: @escaping (Result<CompanyNestedLocationJson,Error>) -> Void)
}

public class LocationService: WorkfinderService, LocationServiceProtocol {
    
    public func fetchLocation(locationUuid: F4SUUID, completion: @escaping (Result<CompanyNestedLocationJson,Error>) -> Void) {
        do {
            let relativePath = "locations/\(locationUuid)"
            let request = try buildRequest(relativePath: relativePath, queryItems: nil, verb: .get)
            performTask(with: request, completion: completion, attempting: #function)
        } catch {
            completion(.failure(error))
        }
    }
}
