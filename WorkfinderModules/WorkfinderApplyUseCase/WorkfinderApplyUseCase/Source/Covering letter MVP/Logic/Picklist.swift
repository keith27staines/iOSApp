
import Foundation

public protocol PicklistProtocol {
    var type: Picklist.PicklistType { get }
    var items: [PicklistItemJson] { get }
    var title: String { get }
    var userInstruction: String { get }
    var selectedItems: [PicklistItemJson] { get }
    var itemSelectedSummary: String { get }
    func selectItem(_ item: PicklistItemJson)
    func deselectItem(_ item: PicklistItemJson)
    func fetchItems(completion: @escaping ((Picklist, Result<[PicklistItemJson],Error>)->Void) )
}

public class Picklist: PicklistProtocol {
    
    public enum PicklistType: Int, CaseIterable {
        case roles
        case skills
        case attributes
        case universities
    }
    
    public let type: PicklistType
    public var itemsSelectedSummary: String?
    public var mimumPicks: Int = 1
    public var maximumPicks: Int = 3
    public var items: [PicklistItemJson]
    public var selectedItems: [PicklistItemJson]
    public var provider: PicklistProvider
    
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
    
    public init(type: PicklistType, maximumPicks: Int) {
        self.type = type
        self.items = []
        self.provider = PicklistProvider(picklistType: type)
        self.selectedItems = []
        self.maximumPicks = maximumPicks
    }
    
    public func fetchItems(completion: @escaping ((Picklist, Result<[PicklistItemJson],Error>)->Void) ) {
        guard items.isEmpty else { return }
        provider.fetchMore { (result) in
            switch result {
            case .success(let items):
                self.items = items
            case .failure(_):
                break
            }
            completion(self,result)
        }
    }
    
    public var title: String {
        switch type {
        case .roles:
            return NSLocalizedString("role", comment: "")
        case .skills:
            return NSLocalizedString("skills", comment: "")
        case .attributes:
            return NSLocalizedString("attributes", comment: "")
        case .universities:
            return NSLocalizedString("universities", comment: "")
        }
    }
    
    public var userInstruction: String {
        switch type {
        case .roles:
            return NSLocalizedString("Select the kind of role you are looking for", comment: "")
        case .skills:
            return NSLocalizedString("Choose up to three employment skills you are hoping to acquire through this Work Experience placement", comment: "")
        case .attributes:
            return NSLocalizedString("Select up to three personal attributes that describe you", comment: "")
        case .universities:
            return NSLocalizedString("Select the university you are currently attending", comment: "")
        }
    }
    
    public var itemSelectedSummary: String {
        switch type {
        case .roles:
            return NSLocalizedString("\(selectedItems.count) selected", comment: "")
        case .skills:
            return NSLocalizedString("\(selectedItems.count) selected", comment: "")
        case .attributes:
            return NSLocalizedString("\(selectedItems.count) selected", comment: "")
        case .universities:
            return NSLocalizedString("\(selectedItems.count) selected", comment: "")
        }
    }
}
