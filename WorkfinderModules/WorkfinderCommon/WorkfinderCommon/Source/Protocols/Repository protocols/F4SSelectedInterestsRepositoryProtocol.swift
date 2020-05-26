
import Foundation

public typealias F4SInterest = String
public typealias F4SInterestSet = Set<F4SInterest>

public protocol F4SSelectedInterestsRepositoryProtocol {
    var allInterestsSet: F4SInterestSet { get set }
    func loadSelectedInterestsArray() -> [F4SInterest]
    func loadSelectedInterestsSet() -> F4SInterestSet
    @discardableResult func saveSelectedInterests(_ interests: [F4SInterest]) -> [F4SInterest]
    @discardableResult func saveSelectedInterests(_ interests: F4SInterestSet) -> F4SInterestSet
    func addSelectedInterests(_ addInterests: [F4SInterest]) -> [F4SInterest]
    func addSelectedInterests(_ addInterests: F4SInterestSet) -> F4SInterestSet
    func removeSelectedInterests(_ removeInterests: [F4SInterest]) -> [F4SInterest]
    func removeSelectedInterests(_ removeInterests: F4SInterestSet) -> F4SInterestSet
    func pruneSelectedInterests(keeping: F4SInterestSet) ->F4SInterestSet
}
