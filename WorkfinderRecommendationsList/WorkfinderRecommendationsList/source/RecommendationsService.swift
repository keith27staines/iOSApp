
import WorkfinderCommon
import WorkfinderServices

public protocol RecommendationsServiceProtocol {
    func fetchRecommendations(userUuid: F4SUUID, completion: @escaping (Result<ServerListJson<Recommendation>, Error>) -> Void)
}

class RecommendationsService: WorkfinderService, RecommendationsServiceProtocol {
    
    func fetchRecommendations(userUuid: F4SUUID, completion: @escaping (Result<ServerListJson<Recommendation>, Error>) -> Void) {
        do {
            let request = try buildRequest(relativePath: "recommendations/", queryItems: nil, verb: .get)
            performTask(with: request, completion: completion, attempting: #function)
        } catch {
            completion(Result<ServerListJson<Recommendation>, Error>.failure(error))
        }
        
    }
}