import WorkfinderCommon

public protocol WorkplaceServiceProtocol {
    func fetchWorkplace(locationUuid: F4SUUID, completion: @escaping (Result<Workplace,Error>) -> Void)
}

public class WorkplaceService: WorkfinderService, WorkplaceServiceProtocol {
    
    public func fetchWorkplace(locationUuid: F4SUUID, completion: @escaping (Result<Workplace,Error>) -> Void) {
        do {
            let relativePath = "locations/\(locationUuid)"
            let request = try buildRequest(relativePath: relativePath, queryItems: nil, verb: .get)
            performTask(with: request, completion: completion, attempting: #function)
        } catch {
            completion(Result<Workplace,Error>.failure(error))
        }
    }
}
