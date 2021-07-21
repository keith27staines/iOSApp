
import WorkfinderCommon

public protocol ProjectServiceProtocol {
    func fetchProject(uuid: String, completion: @escaping (Result<ProjectJson,Error>) -> Void)
    func fetchProjectType(uuid: String, completion: @escaping (Result<ProjectTypeJson,Error>) -> Void)
    func fetchHost(uuid: String, completion: @escaping (Result<HostJson,Error>) -> Void)
}

public class ProjectService: WorkfinderService, ProjectServiceProtocol {
    private let hostService: HostsProviderProtocol
    
    public override init(networkConfig: NetworkConfig) {
        hostService = HostsProvider(networkConfig: networkConfig)
        super.init(networkConfig: networkConfig)
    }
    
    public func fetchProject(uuid: String, completion: @escaping (Result<ProjectJson, Error>) -> Void) {
        do {
            let request = try buildRequest(relativePath: "projects/\(uuid)", queryItems: nil, verb: .get)
            performTask(with: request, verbose: true ,completion: completion, attempting: #function)
        } catch {
            completion(Result<ProjectJson,Error>.failure(error))
        }
    }
    
    public func fetchProjectType(uuid: String, completion: @escaping (Result<ProjectTypeJson, Error>) -> Void) {
        do {
            let request = try buildRequest(relativePath: "project-types/\(uuid)", queryItems: nil, verb: .get)
            performTask(with: request, completion: completion, attempting: #function)
        } catch {
            completion(Result<ProjectTypeJson,Error>.failure(error))
        }
    }
    
    public func fetchHost(uuid: String, completion: @escaping (Result<HostJson,Error>) -> Void) {
        hostService.fetchHost(uuid: uuid, completion: completion)
    }
}
