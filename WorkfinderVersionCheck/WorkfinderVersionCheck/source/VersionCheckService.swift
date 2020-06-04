
import WorkfinderCommon
import WorkfinderServices

public struct VersionJson: Codable {
    var platform: String?
    var version: String?
}

public protocol VersionCheckServiceProtocol: AnyObject {
    func fetchMinimumVersion(completion: @escaping (Result<VersionJson,Error>) -> Void)
}

public class VersionCheckService: WorkfinderService, VersionCheckServiceProtocol {
    
    public func fetchMinimumVersion(completion: @escaping (Result<VersionJson,Error>) -> Void) {
        let path = "min-required-app-version/"
        do {
            let request = try buildRequest(relativePath: path, queryItems: [URLQueryItem(name: "platform", value: "ios")], verb: .get)
            performTask(with: request, completion: completion, attempting: #function)
        } catch {
            completion(Result<VersionJson,Error>.failure(error))
        }
    }
}

