
import Foundation

public class MockF4SInterestsRepository: F4SSelectedInterestsRepositoryProtocol {
    
    public var allInterestsSet = F4SInterestSet()
    var interests = F4SInterestSet()
    
    public init() {}
    
    public func loadSelectedInterestsArray() -> [F4SInterest] {
        return Array(interests)
    }
    
    public func loadSelectedInterestsSet() -> F4SInterestSet {
        return interests
    }
    
    public func saveSelectedInterests(_ interests: [F4SInterest]) -> [F4SInterest] {
        self.interests = Set<F4SInterest>(interests)
        return Array(self.interests)
    }
    
    public func saveSelectedInterests(_ interests: F4SInterestSet) -> F4SInterestSet {
        self.interests = interests
        return self.interests
    }
    
    public func addSelectedInterests(_ addInterests: [F4SInterest]) -> [F4SInterest] {
        self.interests = self.interests.union(addInterests)
        return Array(self.interests)
    }
    
    public func addSelectedInterests(_ addInterests: F4SInterestSet) -> F4SInterestSet {
        self.interests = self.interests.union(addInterests)
        return self.interests
    }
    
    public func removeSelectedInterests(_ removeInterests: [F4SInterest]) -> [F4SInterest] {
        self.interests = self.interests.subtracting(removeInterests)
        return Array(self.interests)
    }
    
    public func removeSelectedInterests(_ removeInterests: F4SInterestSet) -> F4SInterestSet {
        self.interests = self.interests.subtracting(removeInterests)
        return self.interests
    }
    
    public func pruneSelectedInterests(keeping: F4SInterestSet) -> F4SInterestSet {
        self.interests = self.interests.intersection(keeping)
        return self.interests
    }
}
