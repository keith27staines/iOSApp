import WorkfinderCommon

public protocol RecommendationsServiceProtocol {
    func fetchRecommendation(uuid: F4SUUID, completion: @escaping (Result<RecommendationsListItem,Error>) -> Void)
    func fetchRecommendations(completion: @escaping (Result<ServerListJson<RecommendationsListItem>,Error>) -> Void)
    func fetchNextPage(urlString: String, completion: @escaping (Result<ServerListJson<RecommendationsListItem>,Error>) -> Void)
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
            let verbose = false
            let query = [URLQueryItem(name: "ordering", value: "-created_at"), URLQueryItem(name: "limit", value: "30")]
            let request = try buildRequest(relativePath: "recommendations/", queryItems: query, verb: .get)
            performTask(with: request, verbose: verbose, completion: completion, attempting: #function)
        } catch {
            completion(.failure(error))
        }
    }
    
    public func fetchNextPage(urlString: String, completion: @escaping (Result<ServerListJson<RecommendationsListItem>, Error>) -> Void) {
        do {
            let verbose = false
            let request = try buildRequest(path: urlString, queryItems: nil, verb: .get)
            performTask(with: request, verbose: verbose, completion: completion, attempting: #function)
        } catch {
            completion(.failure(error))
        }
    }
}
