
import Foundation
import WorkfinderCommon
import WorkfinderServices

public class Picklist: PicklistProtocol {
    
    public let type: PicklistType
    public var itemsSelectedSummary: String?
    public var mimumPicks: Int = 1
    public var maximumPicks: Int = 3
    public var items: [PicklistItemJson]
    public var selectedItems: [PicklistItemJson]
    public var provider: PicklistProviderProtocol?
    let networkConfig: NetworkConfig
    var filters = [URLQueryItem]()
    
    public func selectItem(_ item: PicklistItemJson) {
        if !selectedItems.contains(where: { (otherItem) -> Bool in
            otherItem.uuid == item.uuid
        }) {
            selectedItems.append(item)
        }
    }
    
    public func deselectItem(_ item: PicklistItemJson) {
        guard let index = selectedItems.firstIndex(where: { (otherItem) -> Bool in
            return otherItem.uuid == item.uuid
        })  else { return }
        selectedItems.remove(at: index)
    }
    
    public init(type: PicklistType, maximumPicks: Int, networkConfig: NetworkConfig) {
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
                        PicklistItemJson(uuid: UUID().uuidString, value: "Server failed to return pick list items again :("),
                        PicklistItemJson(uuid: UUID().uuidString, value: "I'm a smart iphone!"),
                        PicklistItemJson(uuid: UUID().uuidString, value: "I made this up")
                    ]
                }
                completion(self,Result<[PicklistItemJson],Error>.success(self.items))
            case .failure(let error):
                completion(self,Result<[PicklistItemJson],Error>.failure(error))
            }
        }
    }
    
    lazy public var title: String = {
        switch type {
        case .roles:
            return NSLocalizedString("role", comment: "")
        case .skills:
            return NSLocalizedString("skills", comment: "")
        case .attributes:
            return NSLocalizedString("attributes", comment: "")
        case .universities:
            return NSLocalizedString("educational institution", comment: "")
        case .year:
            return NSLocalizedString("year", comment: "")
        case .motivation:
            return NSLocalizedString("motivation", comment: "")
        case .reason:
            return NSLocalizedString("reason", comment: "")
        case .experience:
            return NSLocalizedString("experience", comment: "")
        case .availabilityPeriod:
            return NSLocalizedString("availability", comment: "")
        }
    }()
    
    lazy public var userInstruction: String = {
        switch type {
        case .roles:
            return NSLocalizedString("Select the kind of role you are looking for", comment: "")
        case .skills:
            return NSLocalizedString("Choose up to three employment skills you are hoping to acquire through this Work Experience placement", comment: "")
        case .attributes:
            return NSLocalizedString("Select up to three personal attributes that describe you", comment: "")
        case .universities:
            return NSLocalizedString("Select the university you are currently attending", comment: "")
        case .year:
            return NSLocalizedString("Select your year of study", comment: "")
        case .availabilityPeriod:
            return NSLocalizedString("Select your availability", comment: "")
        case .motivation:
            return NSLocalizedString("your motivation", comment: "")
        case .reason:
            return NSLocalizedString("your reason for applying", comment: "")
        case .experience:
            return NSLocalizedString("Your experience", comment: "")
        }
    }()
    
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
