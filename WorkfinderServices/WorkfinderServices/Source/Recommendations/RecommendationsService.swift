import WorkfinderCommon

public protocol RecommendationsServiceProtocol {
    func fetchRecommendation(uuid: F4SUUID, completion: @escaping (Result<Recommendation,Error>) -> Void)
    func fetchRecommendations(completion: @escaping (Result<ServerListJson<Recommendation>,Error>) -> Void)
}

public class RecommendationsService: WorkfinderService, RecommendationsServiceProtocol {

    public func fetchRecommendation(uuid: F4SUUID, completion: @escaping (Result<Recommendation,Error>) -> Void) {
        do {
            let relativePath = "recommendations/\(uuid)"
            let request = try buildRequest(relativePath: relativePath, queryItems: nil, verb: .get)
            performTask(with: request, completion: completion, attempting: #function)
        } catch {
            completion(Result<Recommendation,Error>.failure(error))
        }
    }
    
    public func fetchRecommendations(completion: @escaping (Result<ServerListJson<Recommendation>, Error>) -> Void) {
        do {
            let relativePath = "recommendations/"
            let request = try buildRequest(relativePath: relativePath, queryItems: nil, verb: .get)
            performTask(with: request, completion: completion, attempting: #function)
        } catch {
            completion(Result<ServerListJson<Recommendation>,Error>.failure(error))
        }
    }
}
