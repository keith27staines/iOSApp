
import WorkfinderCommon
import WorkfinderServices

public protocol RecommendationsServiceProtocol {
    func fetchRecommendations(userUuid: F4SUUID, completion: @escaping (Result<[Recommendation], Error>) -> Void)
}

class RecommendationsService: WorkfinderService, RecommendationsServiceProtocol {
    
    func fetchRecommendations(userUuid: F4SUUID, completion: @escaping (Result<[Recommendation], Error>) -> Void) {
        DispatchQueue.main.async {
            completion(Result<[Recommendation], Error>.failure(WorkfinderError.init(title: "No data", description: "Service is not wired to server")))
        }
    }
}
