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
        case .language:
            service.getLanguagesPicklistcompletion { [weak self] (result) in
                self?.handleServiceResult(result, completion: completion)
            }
        case .gender:
            service.getGendersPicklistcompletion { [weak self] (result) in
                self?.handleServiceResult(result, completion: completion)
            }
        case .ethnicity:
            service.getEthnicitiesPicklistcompletion { [weak self] (result) in
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
    
    private func isItemSelected(id: String) -> Bool {
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

    func selectItemHavingId(_ id: String) -> Bool {
        preselectedIds.insert(id)
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
    case language
    case gender
    case ethnicity
    
    var title: String {
        switch self {
        case .language: return "Languages"
        case .ethnicity: return "Ethnicity"
        case .gender: return "Gender identity"
        }
    }
    
    var showSearchBar: Bool {
        switch self {
        case .language: return true
        case .gender: return false
        case .ethnicity: return false
        }
    }
    
    var instruction: String {
        switch self {
        case .language: return "Select up to 10 languages"
        case .ethnicity: return "Select the ethnicity you most identify with"
        case .gender: return "Select the gender identity you most identify with"
        }
    }
    
    var maxSelections: Int {
        switch self {
        case .ethnicity: return 1
        case .gender: return 1
        case .language: return 10
        }
    }
    
    var reasonForCollection: String {
        switch self {
        case .language: return "For employers who prefer candidates with certain language skills"
        case .gender: return "We collect this information in line with our D&I policy"
        case .ethnicity: return "We collect this information in line with our D&I policy"
        }
    }
}
