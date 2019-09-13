import Foundation
import WorkfinderCommon

public protocol RecommendedCompaniesLocalRepositoryProtocol {
    func loadRecommendations() -> [F4SRecommendation]
    func saveRecommendations(_ recommendations: [F4SRecommendation])
}

public class RecommendedCompaniesLocalRepository : RecommendedCompaniesLocalRepositoryProtocol {
    let localStore: LocalStorageProtocol
    public init(localStore: LocalStorageProtocol) {
        self.localStore = localStore
    }
    
    public func loadRecommendations() -> [F4SRecommendation] {
        guard let data = localStore.value(key: LocalStore.Key.recommendedCompaniesJsonData) as? Data else {
            return []
        }
        let recommendations = try! JSONDecoder().decode([F4SRecommendation].self, from: data)
        return recommendations
    }
    
    public func saveRecommendations(_ recommendations: [F4SRecommendation]) {
        let data = try! JSONEncoder().encode(recommendations)
        localStore.setValue(data, for: LocalStore.Key.recommendedCompaniesJsonData)
    }
}
