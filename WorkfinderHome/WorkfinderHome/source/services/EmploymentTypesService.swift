
import WorkfinderCommon
import WorkfinderServices

protocol EmploymentTypesServiceProtocol {
    func fetch(completion: @escaping (Result<[String],Error>) -> Void)
}

class EmploymentTypesService: WorkfinderService, EmploymentTypesServiceProtocol {
    
    func fetch(completion: @escaping (Result<[String],Error>) -> Void) {
        do {
            let relativePath = "employment-types/"
            let request = try buildRequest(relativePath: relativePath, queryItems: nil, verb: .get)
            performTask(with: request, completion: completion, attempting: #function)
        } catch {
            completion(.failure(error))
        }
    }
}
