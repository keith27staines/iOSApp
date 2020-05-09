
import Foundation
import WorkfinderCommon
import WorkfinderServices

public class Picklist: PicklistProtocol {
    
    public let type: PicklistType
    public var itemsSelectedSummary: String?
    public var mimumPicks: Int = 1
    public var maximumPicks: Int = 3
    public var items: [PicklistItemJson]
    public var otherItem: PicklistItemJson?
    public var selectedItems: [PicklistItemJson]
    public var provider: PicklistProviderProtocol?
    let networkConfig: NetworkConfig
    var filters = [URLQueryItem]()
    
    public func selectItem(_ item: PicklistItemJson) {
        if !selectedItems.contains(where: { (otherItem) -> Bool in
            otherItem.guaranteedUuid == item.guaranteedUuid
        }) {
            selectedItems.append(item)
        }
    }
    
    public func deselectItem(_ item: PicklistItemJson) {
        guard let index = selectedItems.firstIndex(where: { (otherItem) -> Bool in
            return otherItem.guaranteedUuid == item.guaranteedUuid
        })  else { return }
        selectedItems.remove(at: index)
    }
    
    public init(type: PicklistType, otherItem: PicklistItemJson?, maximumPicks: Int, networkConfig: NetworkConfig) {
        self.otherItem = otherItem
        self.type = type
        self.items = []
        self.selectedItems = []
        self.maximumPicks = maximumPicks
        self.networkConfig = networkConfig
        self.provider = makeProvider()
    }
    
    func makeProvider() -> PicklistProviderProtocol? {
        if self.type.providerType == .network {
            return PicklistProvider(picklistType: self.type, networkConfig: networkConfig)
        }
        return nil
    }
    
    public func fetchItems(completion: @escaping ((PicklistProtocol, Result<[PicklistItemJson],Error>)->Void) ) {
        guard items.isEmpty else { return }
        provider?.fetchPicklistItems { (result) in
            switch result {
            case .success(let responseBody):
                self.items = responseBody.results
                if self.items.count == 0 {
                    self.items = [
                        PicklistItemJson(uuid: "hcv1", value: "Server failed to return pick list items again :("),
                        PicklistItemJson(uuid: "hcv2", value: "I'm a smart iphone!"),
                        PicklistItemJson(uuid: "hcv3", value: "I made this up")
                    ]
                }
                self.items.sort { (item1, item2) -> Bool in
                    (item1.guarenteedName < item2.guarenteedName)
                }
                if let otherItem = self.otherItem { self.items.append(otherItem) }
                completion(self,Result<[PicklistItemJson],Error>.success(self.items))
            case .failure(let error):
                completion(self,Result<[PicklistItemJson],Error>.failure(error))
            }
        }
    }
    
    public var itemSelectedSummary: String {
        guard selectedItems.count > 0 else { return "" }
        switch type {
        case .roles:
            return NSLocalizedString("Selected", comment: "")
        case .skills:
            return NSLocalizedString("\(selectedItems.count) selected", comment: "")
        case .attributes:
            return NSLocalizedString("\(selectedItems.count) selected", comment: "")
        case .universities:
            return NSLocalizedString("\(selectedItems.count) selected", comment: "")
        case .year:
            return NSLocalizedString("Selected", comment: "")
        case .availabilityPeriod:
            return NSLocalizedString("Selected", comment: "")
        case .motivation, .reason, .experience:
            return NSLocalizedString("Selected", comment: "")
        }
    }
}
