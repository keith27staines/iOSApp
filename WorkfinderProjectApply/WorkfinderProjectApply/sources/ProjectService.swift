
import WorkfinderCommon
import WorkfinderServices

public protocol ProjectServiceProtocol {
    func fetchProject(uuid: String, completion: @escaping (Result<ProjectJson,Error>) -> Void)
    func fetchProjectType(uuid: String, completion: @escaping (Result<ProjectTypeJson,Error>) -> Void)
}

public class ProjectService: WorkfinderService, ProjectServiceProtocol {
    
    public func fetchProject(uuid: String, completion: @escaping (Result<ProjectJson, Error>) -> Void) {
        do {
            let request = try buildRequest(relativePath: "projects/\(uuid)", queryItems: nil, verb: .get)
            performTask(with: request, completion: completion, attempting: #function)
        } catch {
            completion(Result<ProjectJson,Error>.failure(error))
        }
    }
    
    public func fetchProjectType(uuid: String, completion: @escaping (Result<ProjectTypeJson, Error>) -> Void) {
        do {
            let request = try buildRequest(relativePath: "project_types/\(uuid)", queryItems: nil, verb: .get)
            performTask(with: request, completion: completion, attempting: #function)
        } catch {
            completion(Result<ProjectTypeJson,Error>.failure(error))
        }
    }
}
