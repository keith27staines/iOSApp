import WorkfinderCommon
import WorkfinderServices

public protocol TextSearchPicklistProtocol: class, PicklistProtocol {
    func clearResults()
    func fetchMatches(matchingString: String, completion: @escaping ((Result<PicklistServerJson, Error>) -> Void))
}

public class TextSearchPicklist: Picklist, TextSearchPicklistProtocol {
    
    public func clearResults() {
        items.removeAll()
    }
    
    public func fetchMatches(matchingString: String, completion: @escaping ((Result<PicklistServerJson, Error>) -> Void)) {
        provider?.filters = [
            URLQueryItem(name: "name__icontains", value: matchingString)
        ]
        provider?.fetchPicklistItems(completion: completion)
    }

    public init(type: PicklistType, networkConfig: NetworkConfig) {
        super.init(type: type, maximumPicks: 1, networkConfig: networkConfig)
    }
}
