
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

public class AvailabilityPeriodPicklist: ClientPicklist {
    public init() {
        super.init(type: .availabilityPeriod, maximumPicks: 2)
        items = [
            PicklistItemJson(uuid: "startDate", value: ""),
            PicklistItemJson(uuid: "endDate", value: "")
        ]
    }
}

public class TextblockPicklist: ClientPicklist {
    let placeholder: String
    public init(type: PicklistType, placeholder: String) {
        self.placeholder = placeholder
        super.init(type: type, maximumPicks: 1)
        items = [
            PicklistItemJson(uuid: "text", value: "")
        ]
    }
}

public class UniversityYearPicklist: ClientPicklist {
    
    public init() {
        super.init(type: .year, maximumPicks: 1)
        items = [
            PicklistItemJson(uuid: "1", value: "Year 1"),
            PicklistItemJson(uuid: "2", value: "Year 2"),
            PicklistItemJson(uuid: "3", value: "Year 3"),
            PicklistItemJson(uuid: "4", value: "Year 4"),
            PicklistItemJson(uuid: "5", value: "Year 5"),
            PicklistItemJson(uuid: "6", value: "Year 6"),
            PicklistItemJson(uuid: "7", value: "Year 7"),
        ]
    }
}

public class ClientPicklist: Picklist {
    override public func fetchItems(completion: @escaping ((Picklist, Result<[PicklistItemJson], Error>) -> Void)) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            completion(self, Result<[PicklistItemJson], Error>.success(self.items))
        }
    }
}

public class Picklist: PicklistProtocol {
    
    public enum ProviderType {
        case network
        case clientTextField
        case clientTextblock
        case clientAvailabilityPeriod
    }
    
    public enum PicklistType: Int, CaseIterable {
        case roles
        case skills
        case attributes
        case universities
        case year
        case availabilityPeriod
        case motivation
        case reason
        case experience
        var providerType: ProviderType {
            switch self {
            case .roles, .skills, .attributes, .universities:
                return .network
            case .year:
                return .clientTextField
            case .motivation,.reason, .experience:
                return .clientTextField
            case .availabilityPeriod:
                return .clientAvailabilityPeriod
            }
        }
    }
    
    public let type: PicklistType
    public var itemsSelectedSummary: String?
    public var mimumPicks: Int = 1
    public var maximumPicks: Int = 3
    public var items: [PicklistItemJson]
    public var selectedItems: [PicklistItemJson]
    public var provider: PicklistProvider?
    
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
        self.selectedItems = []
        self.maximumPicks = maximumPicks
        self.provider = makeProvider()
    }
    
    func makeProvider() -> PicklistProvider? {
        if self.type.providerType == .network {
            return PicklistProvider(picklistType: self.type)
        }
        return nil
    }
    
    public func fetchItems(completion: @escaping ((Picklist, Result<[PicklistItemJson],Error>)->Void) ) {
        guard items.isEmpty else { return }
        provider?.fetchMore { (result) in
            switch result {
            case .success(let items):
                self.items = items
            case .failure(_):
                break
            }
            completion(self,result)
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
            return NSLocalizedString("university", comment: "")
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
