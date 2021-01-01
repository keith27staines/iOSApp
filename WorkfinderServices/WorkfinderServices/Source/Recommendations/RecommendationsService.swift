import WorkfinderCommon

public protocol RecommendationsServiceProtocol {
    func fetchRecommendation(uuid: F4SUUID, completion: @escaping (Result<RecommendationsListItem,Error>) -> Void)
    func fetchRecommendations(completion: @escaping (Result<ServerListJson<RecommendationsListItem>,Error>) -> Void)
}

public class RecommendationsService: WorkfinderService, RecommendationsServiceProtocol {
    
    public func fetchRecommendation(uuid: F4SUUID, completion: @escaping (Result<RecommendationsListItem,Error>) -> Void) {
        do {
            let relativePath = "recommendations/\(uuid)/"
            let request = try buildRequest(relativePath: relativePath, queryItems: nil, verb: .get)
            performTask(with: request, completion: completion, attempting: #function)
        } catch {
            completion(.failure(error))
        }
    }
    
    public func fetchRecommendations(completion: @escaping (Result<ServerListJson<RecommendationsListItem>, Error>) -> Void) {
        do {
            let query = [URLQueryItem(name: "ordering", value: "-created_at")]
            let request = try buildRequest(relativePath: "recommendations/", queryItems: query, verb: .get)
            performTask(with: request, verbose: false, completion: completion, attempting: #function)
        } catch {
            completion(.failure(error))
        }
        
    }
}
