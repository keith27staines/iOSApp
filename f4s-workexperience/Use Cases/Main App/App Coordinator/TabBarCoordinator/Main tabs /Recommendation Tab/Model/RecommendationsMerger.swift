import Foundation
import WorkfinderCommon

public class RecommendedCompaniesMerger {
    private (set) var fetchedFromServer: [RecommendationProtocol]? = nil
    private (set) var fetchedFromLocalStore: [RecommendationProtocol] = []
    private (set) var recommendations: [RecommendationProtocol] = []
    private (set) var addedSet: Set<Recommendation> = []
    private (set) var removedSet: Set<Recommendation> = []
    
    public var numberAddedSinceLastReset: Int { return addedSet.count }
    
    public init(fetchedFromLocalStore: [RecommendationProtocol]) {
        reset(withFetchFromLocalStore: fetchedFromLocalStore)
    }
    
    public func reset(withFetchFromLocalStore fetch: [RecommendationProtocol]) {
        self.fetchedFromLocalStore = fetch
        self.fetchedFromServer = nil
        self.recommendations = fetchedFromLocalStore
        self.addedSet = []
        self.removedSet = []
    }
    
    public func merge(fetchedFromServer: [RecommendationProtocol]?) -> [RecommendationProtocol] {
        self.fetchedFromServer = fetchedFromServer
        guard let fetchedFromServer = fetchedFromServer else { return recommendations }
        let currentSet = setFromArray(recommendations: recommendations)
        let fetchedSet = setFromArray(recommendations: fetchedFromServer)
        let newlyRemoved = currentSet.subtracting(fetchedSet)
        let newlyAdded = fetchedSet.subtracting(currentSet)
        removedSet = removedSet.union(newlyRemoved)
        addedSet = addedSet.union(newlyAdded)
        recommendations = fetchedFromServer
        return fetchedFromServer
    }
    
    func setFromArray(recommendations: [RecommendationProtocol]) -> Set<Recommendation> {
        let array = recommendations.map { (recommendation) -> Recommendation in
            return Recommendation(recommendation: recommendation)
        }
        return Set<Recommendation>(array)
    }
}
