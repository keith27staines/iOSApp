
import Foundation
import WorkfinderCommon
import WorkfinderServices

public class Picklist: PicklistProtocol {
    
    public func updateSelectedTextValue(_ text: String) {
        if isOtherSelected {
            guard var otherItem = self.otherItem else { return }
            otherItem.otherValue = text
            self.otherItem = otherItem
            deselectAll()
            selectItem(otherItem)
            if text.isEmpty { deselectAll() }
        } else if selectedItems.count > 0 {
            selectedItems[0].value = text
        }
    }
    
    public let type: PicklistType
    public var itemsSelectedSummary: String?
    public var mimumPicks: Int = 1
    public var maximumPicks: Int = 3
    public var items: [PicklistItemJson]
    public private (set) var otherItem: PicklistItemJson?
    public private (set) var selectedItems: [PicklistItemJson]
    public var provider: PicklistProviderProtocol?
    let networkConfig: NetworkConfig
    var filters = [URLQueryItem]()

    public func selectItems(_ items: [PicklistItemJson]) {
        items.forEach { (item) in
            if item.isOther { self.otherItem = item }
            selectItem(item)
        }
    }
    
    public func selectItem(_ item: PicklistItemJson) {
        if !selectedItems.contains(where: { (selectedItem) -> Bool in
            selectedItem.guaranteedUuid == item.guaranteedUuid
        }) {
            selectedItems.append(item)
        }
    }
    
    public func deselectItem(_ item: PicklistItemJson) {
        guard let index = selectedItems.firstIndex(where: { (selectedItem) -> Bool in
            return selectedItem.guaranteedUuid == item.guaranteedUuid
        })  else { return }
        selectedItems.remove(at: index)
    }
    
    public func deselectAll() { selectedItems = [] }
    
    public init(type: PicklistType, networkConfig: NetworkConfig) {
        self.otherItem = type.isOtherable ? PicklistItemJson(uuid: PicklistItemJson.otherItemUuid, value: "Other") : nil
        self.type = type
        self.items = []
        self.selectedItems = []
        self.maximumPicks = type.maxItems
        self.networkConfig = networkConfig
        self.provider = makeProvider()
    }
    
    func makeProvider() -> PicklistProviderProtocol? {
        if self.type.providerType == .network {
            return PicklistProvider(picklistType: self.type, networkConfig: networkConfig)
        }
        return nil
    }
    public var isOtherSelected: Bool {
        guard let first = selectedItems.first else { return false }
        return first.isOther
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
        guard selectedItems.count > 0 else { return NSLocalizedString("Choose", comment: "") }
        switch maximumPicks {
        case 1: return NSLocalizedString("Selected", comment: "")
        default: return NSLocalizedString("\(selectedItems.count) selected", comment: "")
        }
    }
}
