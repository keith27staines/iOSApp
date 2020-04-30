
import Foundation
import WorkfinderCommon

public class F4SInterestsRepository : F4SInterestsRepositoryProtocol {
    
    public var allInterestsSet = F4SInterestSet()
    let localStore: LocalStorageProtocol
    
    public init(localStore: LocalStorageProtocol) {
        self.localStore = localStore
    }
    
    public func loadInterestsArray() -> [F4SInterest] {
        guard let data: Data = localStore.value(key: LocalStore.Key.interests) as? Data else {
            return []
        }
        let decoder = JSONDecoder()
        return try! decoder.decode([F4SInterest].self, from: data)
    }
    
    public func loadInterestsSet() -> Set<F4SInterest> {
        let interests = loadInterestsArray()
        return Set<F4SInterest>(interests)
    }
    
    @discardableResult
    public func saveInterests(_ interests: [F4SInterest]) -> [F4SInterest] {
        let interestsSet = Set<F4SInterest>(interests)
        saveInterests(interestsSet)
        return loadInterestsArray()
    }
    
    @discardableResult
    public func saveInterests(_ interests: F4SInterestSet) -> F4SInterestSet {
        let interestsArray: [F4SInterest] = Array(interests)
        let encoder = JSONEncoder()
        let data = try! encoder.encode(interestsArray)
        localStore.setValue(data, for: LocalStore.Key.interests)
        return loadInterestsSet()
    }
    
    @discardableResult
    public func addInterests(_ addInterests: [F4SInterest]) -> [F4SInterest] {
        let addInterestsSet = Set<F4SInterest>(addInterests)
        self.addInterests(addInterestsSet)
        return loadInterestsArray()
    }
    
    @discardableResult
    public func addInterests(_ addInterests: F4SInterestSet) -> F4SInterestSet {
        let interests = loadInterestsSet()
        saveInterests(interests.union(addInterests))
        return loadInterestsSet()
    }
    
    @discardableResult
    public func removeInterests(_ removeInterests: [F4SInterest]) -> [F4SInterest] {
        let removeSet = Set<F4SInterest>(removeInterests)
        self.removeInterests(removeSet)
        return loadInterestsArray()
    }
    
    @discardableResult
    public func removeInterests(_ removeInterests: F4SInterestSet) -> F4SInterestSet {
        let interests = loadInterestsSet()
        saveInterests(interests.subtracting(removeInterests))
        return loadInterestsSet()
    }
    
    /// Prunes interests from the store that are not members of the specified list
    /// - Returns: the remaining interests in the store
    @discardableResult
    public func pruneInterests(keeping: F4SInterestSet) -> F4SInterestSet {
        let interests = loadInterestsSet()
        let intersection = interests.intersection(keeping)
        return saveInterests(intersection)
    }
}



