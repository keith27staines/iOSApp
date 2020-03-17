
import Foundation

public typealias F4SInterestSet = Set<F4SInterest>

public protocol F4SInterestsRepositoryProtocol {
    func loadInterestsArray() -> [F4SInterest]
    func loadInterestsSet() -> F4SInterestSet
    func saveInterests(_ interests: [F4SInterest]) -> [F4SInterest]
    func saveInterests(_ interests: F4SInterestSet) -> F4SInterestSet
    func addInterests(_ addInterests: [F4SInterest]) -> [F4SInterest]
    func addInterests(_ addInterests: F4SInterestSet) -> F4SInterestSet
    func removeInterests(_ removeInterests: [F4SInterest]) -> [F4SInterest]
    func removeInterests(_ removeInterests: F4SInterestSet) -> F4SInterestSet
    func pruneInterests(keeping: [F4SInterest]) ->F4SInterestSet
}
