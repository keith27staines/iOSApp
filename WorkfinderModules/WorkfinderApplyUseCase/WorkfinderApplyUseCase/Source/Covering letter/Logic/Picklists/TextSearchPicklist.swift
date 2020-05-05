import WorkfinderCommon
import WorkfinderServices

public protocol TextSearchPicklistProtocol: class, PicklistProtocol {
    func clearResults()
    func fetchMatches(matchingString: String, completion: @escaping ((Result<PicklistServerJson, Error>) -> Void))
}

public class TextSearchPicklist: Picklist, TextSearchPicklistProtocol {
    
    public func clearResults() {
        selectedItems = []
        items.removeAll()
    }
    
    public func fetchMatches(matchingString: String, completion: @escaping ((Result<PicklistServerJson, Error>) -> Void)) {
        provider?.filters = [
            URLQueryItem(name: "name__icontains", value: matchingString)
        ]
        provider?.fetchPicklistItems(completion: { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let resultsJson):
                self.items = resultsJson.results
                self.items.sort { (item1, item2) -> Bool in
                    (item1.guarenteedName < item2.guarenteedName)
                }
                completion(Result<PicklistServerJson, Error>.success(resultsJson))
            case .failure(let error):
                completion(Result<PicklistServerJson, Error>.failure(error))
            }
        })
    }

    public init(type: PicklistType, otherItem: PicklistItemJson?, networkConfig: NetworkConfig) {
        super.init(type: type, otherItem: otherItem, maximumPicks: 1, networkConfig: networkConfig)
    }
}
