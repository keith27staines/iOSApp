
import WorkfinderCommon
import WorkfinderServices

protocol SkillAcquiredTypesServiceProtocol {
    func fetch(completion: @escaping (Result<[String],Error>) -> Void)
}

class SkillAcquiredTypesService: WorkfinderService, SkillAcquiredTypesServiceProtocol {
    
    func fetch(completion: @escaping (Result<[String],Error>) -> Void) {
        do {
            let relativePath = "skills-acquired/"
            let request = try buildRequest(relativePath: relativePath, queryItems: nil, verb: .get)
            performTask(with: request, completion: completion, attempting: #function)
        } catch {
            completion(.failure(error))
        }
    }
}
