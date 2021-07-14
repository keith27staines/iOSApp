
import WorkfinderCommon

protocol PicklistsStoreProtocol {
    var allPicklistsDictionary: PicklistsDictionary { get }
    func load() -> PicklistsDictionary
    func save()
}

class PicklistsStore: PicklistsStoreProtocol {
    let networkConfig: NetworkConfig
    let localStore:LocalStorageProtocol
    
    init(networkConfig: NetworkConfig, localStore:LocalStorageProtocol) {
        self.networkConfig = networkConfig
        self.localStore = localStore
    }
    
    var allPicklistsDictionary: PicklistsDictionary = [:]
    
    func load() -> PicklistsDictionary {
        let picklists = buildPicklists()
        let selectedItems = loadSelectedItems()
        assignSelectedValues(picklists: picklists, selectedItems: selectedItems)
        allPicklistsDictionary = picklists
        return picklists
    }
    
    func loadSelectedItems() -> [PicklistType: [PicklistItemJson]] {
        typealias ItemsDictionary = [PicklistType: [PicklistItemJson]]
        guard
            let data = localStore.value(key: LocalStore.Key.picklistsSelectedValuesData) as? Data,
            var items = try? JSONDecoder().decode(ItemsDictionary.self, from: data)
            else {
            return [:]
        }
        items[.strongestSkills] = nil
        items[.attributes] = nil
        return items
    }
    
    func save() {
        var items = [PicklistType:[PicklistItemJson]]()
        allPicklistsDictionary.forEach { (key, picklist) in
            switch key {
            case .strongestSkills, .attributes:
                break
            default:
                items[key] = picklist.selectedItems            
            }
        }
        let data = try? JSONEncoder().encode(items)
        localStore.setValue(data, for: LocalStore.Key.picklistsSelectedValuesData)
    }
    
    func assignSelectedValues(picklists: PicklistsDictionary,
                              selectedItems: [PicklistType: [PicklistItemJson]]) {
        picklists.forEach { (key, picklist) in
            picklist.deselectAll()
            picklist.selectItems(selectedItems[key] ?? [])
        }
    }
    
    func buildPicklists() -> PicklistsDictionary {
        var lists = PicklistsDictionary()
        PicklistType.allCases.forEach { (type) in
            switch type {
            case .year,
                 .subject,
                 .placementType,
                 .project,
                 .duration,
                 .skills,
                 .strongestSkills,
                 .attributes:
                lists[type] = Picklist(type: type, networkConfig: networkConfig)
            case .institutions:
                lists[type] = TextSearchPicklist(type: type, networkConfig: networkConfig)
            case .motivation,
                 .experience:
                lists[type] = TextblockPicklist(type: type, networkConfig: networkConfig)
            case .availabilityPeriod:
                lists[type] = AvailabilityPeriodPicklist(networkConfig: networkConfig)
            }
        }
        return lists
    }
}

