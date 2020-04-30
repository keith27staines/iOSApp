
import Foundation

public class MockF4SInterestsRepository: F4SInterestsRepositoryProtocol {
    
    public var allInterestsSet = F4SInterestSet()
    var interests = F4SInterestSet()
    
    public init() {}
    
    public func loadInterestsArray() -> [F4SInterest] {
        return Array(interests)
    }
    
    public func loadInterestsSet() -> F4SInterestSet {
        return interests
    }
    
    public func saveInterests(_ interests: [F4SInterest]) -> [F4SInterest] {
        self.interests = Set<F4SInterest>(interests)
        return Array(self.interests)
    }
    
    public func saveInterests(_ interests: F4SInterestSet) -> F4SInterestSet {
        self.interests = interests
        return self.interests
    }
    
    public func addInterests(_ addInterests: [F4SInterest]) -> [F4SInterest] {
        self.interests = self.interests.union(addInterests)
        return Array(self.interests)
    }
    
    public func addInterests(_ addInterests: F4SInterestSet) -> F4SInterestSet {
        self.interests = self.interests.union(addInterests)
        return self.interests
    }
    
    public func removeInterests(_ removeInterests: [F4SInterest]) -> [F4SInterest] {
        self.interests = self.interests.subtracting(removeInterests)
        return Array(self.interests)
    }
    
    public func removeInterests(_ removeInterests: F4SInterestSet) -> F4SInterestSet {
        self.interests = self.interests.subtracting(removeInterests)
        return self.interests
    }
    
    public func pruneInterests(keeping: F4SInterestSet) -> F4SInterestSet {
        self.interests = self.interests.intersection(keeping)
        return self.interests
    }
}
