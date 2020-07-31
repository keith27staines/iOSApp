
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
    public var isLoaded: Bool = false
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
    
    public func deselectAll() {
        selectedItems = []
    }
    
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
                self.isLoaded = true
                self.items = responseBody.results
                if self.items.count == 0 {
                    self.items = [
                    ]
                }
                if self.type == .institutions {
                    self.items.sort { (item1, item2) -> Bool in
                        (item1.guarenteedName < item2.guarenteedName)
                    }
                }
                if let otherItem = self.otherItem { self.items.append(otherItem) }
                completion(self,Result<[PicklistItemJson],Error>.success(self.items))
            case .failure(let error):
                self.isLoaded = false
                completion(self,Result<[PicklistItemJson],Error>.failure(error))
            }
        }
    }
    
    public var itemSelectedSummary: String {
        guard !isPopulated else { return "COMPLETED" }
        switch type {
        case .motivation: return "(In as many words describes what motivates you)"
        case .experience: return "(In as many words describe your experience)"
        case .year: return "(Please select a year)"
        case .subject: return "(Please select your main subject of study)"
        case .institutions: return "(Please select from our list of options)"
        case .placementType: return "(Please select from our list of options)"
        case .project: return "(Please select from our list of options)"
        case .availabilityPeriod: return "(Please select your availability)"
        case .duration: return "(Please select your preferred duration)"
        case .attributes: return "(Please select up to three from our list)"
        case .skills: return "(Choose up three employment skills you are hoping to acquire through this placement)"
        }
    }
}
