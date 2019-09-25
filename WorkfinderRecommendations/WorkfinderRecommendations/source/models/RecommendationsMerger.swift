import Foundation
import WorkfinderCommon

public class RecommendedCompaniesMerger {
    private (set) var fetchedFromServer: [F4SRecommendationProtocol]? = nil
    private (set) var fetchedFromLocalStore: [F4SRecommendationProtocol] = []
    private (set) var recommendations: [F4SRecommendationProtocol] = []
    private (set) var addedSet: Set<F4SRecommendation> = []
    private (set) var removedSet: Set<F4SRecommendation> = []
    
    public var numberAddedSinceLastReset: Int { return addedSet.count }
    
    public init(fetchedFromLocalStore: [F4SRecommendationProtocol]) {
        reset(withFetchFromLocalStore: fetchedFromLocalStore)
    }
    
    public func reset(withFetchFromLocalStore fetch: [F4SRecommendationProtocol]) {
        self.fetchedFromLocalStore = fetch
        self.fetchedFromServer = nil
        self.recommendations = fetchedFromLocalStore
        self.addedSet = []
        self.removedSet = []
    }
    
    public func merge(fetchedFromServer: [F4SRecommendationProtocol]?) -> [F4SRecommendationProtocol] {
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
    
    func setFromArray(recommendations: [F4SRecommendationProtocol]) -> Set<F4SRecommendation> {
        let array = recommendations.map { (recommendation) -> F4SRecommendation in
            return F4SRecommendation(recommendation: recommendation)
        }
        return Set<F4SRecommendation>(array)
    }
}
