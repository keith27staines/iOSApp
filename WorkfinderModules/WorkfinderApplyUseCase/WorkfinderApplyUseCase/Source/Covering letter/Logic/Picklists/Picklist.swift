
import Foundation
import WorkfinderCommon
import WorkfinderServices

public class Picklist: PicklistProtocol {
    
    public func updateSelectedTextValue(_ text: String) {
        if isOtherSelected {
            otherItem?.otherValue = text
            if text.isEmpty { deselectAll() }
        } else if selectedItems.count > 0 {
            selectedItems[0].value = text
        }
    }
    
    public static let otherItemUuid = "otherUuid"
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
        items.forEach { (item) in selectItem(item) }
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
    public var isOtherSelected: Bool {
        guard let firstUuid = selectedItems.first?.guaranteedUuid else { return false }
        return firstUuid == Picklist.otherItemUuid
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
        guard selectedItems.count > 0 else { return "Choose" }
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
