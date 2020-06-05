import WorkfinderCommon

public protocol WorkplaceServiceProtocol {
    func fetchWorkplace(locationUuid: F4SUUID, completion: @escaping (Result<CompanyWorkplace,Error>) -> Void)
}

public class WorkplaceService: WorkfinderService, WorkplaceServiceProtocol {
    
    public func fetchWorkplace(locationUuid: F4SUUID, completion: @escaping (Result<CompanyWorkplace,Error>) -> Void) {
        do {
            let relativePath = "locations/\(locationUuid)"
            let request = try buildRequest(relativePath: relativePath, queryItems: nil, verb: .get)
            performTask(with: request, completion: completion, attempting: #function)
        } catch {
            completion(Result<CompanyWorkplace,Error>.failure(error))
        }
    }

}
