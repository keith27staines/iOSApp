import Foundation
import WorkfinderCommon

public protocol RecommendedCompaniesLocalRepositoryProtocol {
    func loadRecommendations() -> [Recommendation]
    func saveRecommendations(_ recommendations: [Recommendation])
}

public class RecommendedCompaniesLocalRepository : RecommendedCompaniesLocalRepositoryProtocol {
    let localStore: LocalStorageProtocol
    public init(localStore: LocalStorageProtocol) {
        self.localStore = localStore
    }
    
    public func loadRecommendations() -> [Recommendation] {
        guard let data = localStore.value(key: LocalStore.Key.recommendedCompaniesJsonData) as? Data else {
            return []
        }
        let recommendations = try! JSONDecoder().decode([Recommendation].self, from: data)
        return recommendations
    }
    
    public func saveRecommendations(_ recommendations: [Recommendation]) {
        let data = try! JSONEncoder().encode(recommendations)
        localStore.setValue(data, for: LocalStore.Key.recommendedCompaniesJsonData)
    }
}
