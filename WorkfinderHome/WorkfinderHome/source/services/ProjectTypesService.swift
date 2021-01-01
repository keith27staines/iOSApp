
import WorkfinderCommon
import WorkfinderServices

protocol ProjectTypesServiceProtocol {
    func fetch(completion: @escaping (Result<[String],Error>) -> Void)
}

class ProjectTypesService: WorkfinderService, ProjectTypesServiceProtocol {
    
    func fetch(completion: @escaping (Result<[String],Error>) -> Void) {
        do {
            let relativePath = "project-types/"
            let request = try buildRequest(relativePath: relativePath, queryItems: nil, verb: .get)
            performTask(with: request, completion: completion, attempting: #function)
        } catch {
            completion(.failure(error))
        }
    }
}
