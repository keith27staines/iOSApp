
import Foundation
import WorkfinderCommon

public class F4SSelectedInterestsRepository : F4SSelectedInterestsRepositoryProtocol {
    
    public var allInterestsSet = F4SInterestSet()
    let localStore: LocalStorageProtocol
    
    public init(localStore: LocalStorageProtocol) {
        self.localStore = localStore
    }
    
    public func loadSelectedInterestsArray() -> [F4SInterest] {
        guard let data: Data = localStore.value(key: LocalStore.Key.interests) as? Data else {
            return []
        }
        let decoder = JSONDecoder()
        return try! decoder.decode([F4SInterest].self, from: data)
    }
    
    public func loadSelectedInterestsSet() -> Set<F4SInterest> {
        let interests = loadSelectedInterestsArray()
        return Set<F4SInterest>(interests)
    }
    
    @discardableResult
    public func saveSelectedInterests(_ interests: [F4SInterest]) -> [F4SInterest] {
        let encoder = JSONEncoder()
        let data = try! encoder.encode(interests)
        localStore.setValue(data, for: LocalStore.Key.interests)
        return interests
    }
    
    @discardableResult
    public func saveSelectedInterests(_ interests: F4SInterestSet) -> F4SInterestSet {
        let interestsArray: [F4SInterest] = Array(interests)
        saveSelectedInterests(interestsArray)
        return interests
    }
    
    @discardableResult
    public func addSelectedInterests(_ addInterests: [F4SInterest]) -> [F4SInterest] {
        let addInterestsSet = Set<F4SInterest>(addInterests)
        self.addSelectedInterests(addInterestsSet)
        return loadSelectedInterestsArray()
    }
    
    @discardableResult
    public func addSelectedInterests(_ addInterests: F4SInterestSet) -> F4SInterestSet {
        let interests = loadSelectedInterestsSet()
        saveSelectedInterests(interests.union(addInterests))
        return loadSelectedInterestsSet()
    }
    
    @discardableResult
    public func removeSelectedInterests(_ removeInterests: [F4SInterest]) -> [F4SInterest] {
        let removeSet = Set<F4SInterest>(removeInterests)
        self.removeSelectedInterests(removeSet)
        return loadSelectedInterestsArray()
    }
    
    @discardableResult
    public func removeSelectedInterests(_ removeInterests: F4SInterestSet) -> F4SInterestSet {
        let interests = loadSelectedInterestsSet()
        saveSelectedInterests(interests.subtracting(removeInterests))
        return loadSelectedInterestsSet()
    }
    
    /// Prunes interests from the store that are not members of the specified list
    /// - Returns: the remaining interests in the store
    @discardableResult
    public func pruneSelectedInterests(keeping: F4SInterestSet) -> F4SInterestSet {
        let interests = loadSelectedInterestsSet()
        let intersection = interests.intersection(keeping)
        return saveSelectedInterests(intersection)
    }
}



