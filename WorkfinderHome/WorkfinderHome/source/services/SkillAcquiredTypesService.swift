
import WorkfinderCommon
import WorkfinderServices

protocol SkillAcquiredTypesServiceProtocol {
    func fetch(completion: @escaping (Result<[String],Error>) -> Void)
}

class SkillAcquiredTypesService: WorkfinderService, SkillAcquiredTypesServiceProtocol {
    
    func fetch(completion: @escaping (Result<[String],Error>) -> Void) {
        fetchProjectTemplates { (result) in
            switch result {
            case .success(let json):
                let strings = json.results.reduce(Set<String>()) { (result, template) -> Set<String> in
                    result.union(template.skills_acquired)
                }
                completion(.success(Array(strings)))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func fetchProjectTemplates(completion: @escaping (Result<ServerListJson<ProjectTemplate>,Error>) -> Void) {
        do {
            let relativePath = "project-templates/"
            let request = try buildRequest(relativePath: relativePath, queryItems: nil, verb: .get)
            performTask(with: request, completion: completion, attempting: #function)
        } catch {
            completion(.failure(error))
        }
    }
}

private struct ProjectTemplate: Codable {
    var skills_acquired: [String]
}
