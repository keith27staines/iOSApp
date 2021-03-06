//
//  Picklist.swift
//  WorkfinderCandidateProfile
//
//  Created by Keith Staines on 13/04/2021.
//

import Foundation
import WorkfinderCommon
import WorkfinderServices

class AccountPicklist {
    var service: AccountServiceProtocol
    var type: AccountPicklistType
    var unFiltereditems: [IdentifiedAndNamed] = []
    var filteredItems:  [IdentifiedAndNamed] = []
    var preselectedIds = Set<String>()
    var selectionCount: Int {
        let preselected = preselectedIds.count
        let selected = selectedItems.count
        return max(preselected, selected)
    }
    
    private (set) var selectedItems: [IdentifiedAndNamed] = []
    private var filterString: String? = nil
    
    init(type: AccountPicklistType, service: AccountServiceProtocol) {
        self.type = type
        self.service = service
    }
    
    var isLocallySynchronised: Bool = false
    
    func applyFilter(filter: String?) {
        self.filterString = filter
        guard let filter = filter?.trimmingCharacters(in: .whitespaces), !filter.isEmpty else {
            filteredItems = unFiltereditems
            return
        }
        filteredItems = unFiltereditems.filter({ (item) -> Bool in
            item.name?.lowercased().contains(filter.lowercased()) ?? false
        })
    }
    
    func reload(completion: @escaping (Error?) -> Void) {
        switch type {
        case .countryOfResidence:
            service.getCountriesPicklist { [weak self] (result) in
                self?.handleServiceResult(result, completion: completion)
            }
        case .language:
            service.getLanguagesPicklist { [weak self] (result) in
                self?.handleServiceResult(result, completion: completion)
            }
        case .educationLevel:
            service.getEducationLevelsPicklist { [weak self] (result) in
                self?.handleServiceResult(result, completion: completion)
            }
        case .gender:
            service.getGendersPicklist { [weak self] (result) in
                self?.handleServiceResult(result, completion: completion)
            }
        case .ethnicity:
            service.getEthnicitiesPicklist { [weak self] (result) in
                self?.handleServiceResult(result, completion: completion)
            }
        case .strongestSkills:
            service.getSkillsPicklist { [weak self] (result) in
                self?.handleServiceResult(result, completion: completion)
            }
        case .personalAttributes:
            service.getPersonalAttributesPicklist { [weak self] (result) in
                self?.handleServiceResult(result, completion: completion)
            }
        }
    }
    
    private func handleServiceResult<A: IdentifiedAndNamed>(_ result: Result<[A], Error>, completion: (Error?) -> Void) {
        switch result {
        case .success(let items):
            self.unFiltereditems = items
            applyFilter(filter: filterString)
            preselectedIds.forEach { (id) in
                _ = selectItemHavingId(id)
                preselectedIds.remove(id)
            }
            completion(nil)
        case .failure(let error):
            completion(error)
        }
    }
    
    func itemForIndexPath(_ indexPath: IndexPath) -> IdentifiedAndNamed {
        let section = indexPath.section
        let row = indexPath.row
        return itemsForSection(section: section)[row]
    }
    
    func isItemSelected(id: String) -> Bool {
        selectedItemFromId(id) == nil ? false : true
    }
    
    func isItemSelectedAtIndexPath(_ indexPath: IndexPath) -> Bool {
        guard let id = itemForIndexPath(indexPath).id else { return false }
        return isItemSelected(id: id)
    }

    var sections: [String] {
        var sections = [String]()
        filteredItems.forEach { (item) in
            if !sections.contains(where: { (category) in
                category == item.category ?? ""
            }) {
                sections.append(item.category ?? "")
            }
        }
        return sections
    }
    
    func numberOfItemsForSection(_ section: Int) -> Int {
        itemsForSection(section: section).count
    }
}

extension AccountPicklist {
    private func itemsForSection(section: Int) -> [IdentifiedAndNamed] {
        let sectionName = sections[section]
        return filteredItems.filter { (item) in
            item.category ?? "" == sectionName
        }
    }
    
    func deselectAll() {
        selectedItems = []
    }
    
    func preselectItems(ids: [String]) {
        deselectAll()
        let nonEmptyIds = ids.compactMap { id in
            return id.count == 0 ? nil : id
        }
        preselectedIds = Set<String>(nonEmptyIds)
    }

    func selectItemHavingId(_ id: String) -> Bool {
        let itemOrNil = itemFromId(id)
        let selectedItem = selectedItemFromId(id)
        guard selectedItem == nil else { return false } // already selected
        guard let item = itemOrNil else { return false } // no matching item to select
        guard selectedItems.count < type.maxSelections else { return false }
        selectedItems.append(item)
        return true
    }
    
    func firstSelectedItem() -> IdentifiedAndNamed? {
        selectedItems.first
    }
    
    func indexPathForItem(with id: String) -> IndexPath? {
        for sectionIndex in 0..<sections.count {
            for rowIndex in 0..<itemsForSection(section: sectionIndex).count {
                let indexPath = IndexPath(row: rowIndex, section: sectionIndex)
                let item = itemForIndexPath(indexPath)
                if item.id == id { return IndexPath(row: rowIndex, section: sectionIndex) }
            }
        }
        return nil
    }
    
    func deselectItemWithId(_ id: String) -> Bool {
        preselectedIds.remove(id)
        guard isItemSelected(id: id) else { return false }
        selectedItems.removeAll() { (item) -> Bool in
            item.id == id
        }
        return true
    }
    
    private func itemFromId(_ id: String) -> IdentifiedAndNamed? {
        filteredItems.first { (item) -> Bool in
            item.id == id
        }
    }
    
    private func selectedItemFromId(_ id: String) -> IdentifiedAndNamed? {
        selectedItems.first { (item) -> Bool in
            item.id == id
        }
    }
}

enum AccountPicklistType: Int, CaseIterable {
    case countryOfResidence
    case language
    case educationLevel
    case gender
    case ethnicity
    case strongestSkills
    case personalAttributes
    
    var title: String {
        switch self {
        case .countryOfResidence: return "Country of Residence"
        case .language: return "Languages you are proficient in"
        case .educationLevel: return "Current Educational Level"
        case .ethnicity: return "Ethnicity"
        case .gender: return "Gender identity"
        case .strongestSkills: return "Strongest skills"
        case .personalAttributes: return "Personal attributes"
        }
    }
    
    var showSearchBar: Bool {
        switch self {
        case .countryOfResidence: return true
        case .language: return true
        default: return false
        }
    }
    
    var instruction: String {
        switch self {
        case .countryOfResidence: return "Select your country of residence"
        case .language: return "Select up to 10 languages"
        case .educationLevel: return "Select your current education level"
        case .ethnicity: return "Select the ethnicity you most identify with"
        case .gender: return "Select the gender identity you most identify with"
        case .strongestSkills: return "Select your strongest skills"
        case .personalAttributes: return "Select your personal attributes"
        }
    }
    
    var maxSelections: Int {
        switch self {
        case .countryOfResidence: return 1
        case .ethnicity: return 1
        case .educationLevel: return 1
        case .gender: return 1
        case .language: return 10
        case .strongestSkills: return 1000
        case .personalAttributes: return 1000
        }
    }
    
    var reasonForCollection: String {
        switch self {
        case .countryOfResidence: return "Select a country for personalised and localised opportunities"
        case .language: return "Giving us this information allows us to bring to your attention roles from employers who have specific language needs"
        case .educationLevel: return "Some roles require candidates to have specific qualifications and we use this to recommend suitable roles and opportunitites to you"
        case .gender: return "We collect this information in line with our D&I policy"
        case .ethnicity: return "We collect this information in line with our D&I policy"
        case .strongestSkills: return "This information will allow us to make better recommendations to you"
        case .personalAttributes: return "This information will allow us to make better recommendations to you"
        }
    }
}
