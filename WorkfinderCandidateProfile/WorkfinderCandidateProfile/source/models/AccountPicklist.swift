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
    var items: [IdentifiedAndNamed] = []
    private (set) var selectedItems: [IdentifiedAndNamed] = []
    
    init(type: AccountPicklistType, service: AccountServiceProtocol) {
        self.type = type
        self.service = service
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
            self.items = items
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
    
    func isItemSelectedAtIndexPath(_ indexPath: IndexPath) -> Bool {
        guard let id = itemForIndexPath(indexPath).id else { return false }
        return selectedItemFromId(id) == nil ? false : true
    }
    
    func toggleSelectionAtIndexPath(_ indexPath: IndexPath) {
        guard let id = itemForIndexPath(indexPath).id else { return }
        switch isItemSelectedAtIndexPath(indexPath) {
        case true:
            deselectItemWithId(id)
        case false:
            selectItemHavingId(id)
        }
    }

    var sections: [String] {
        var sections = [String]()
        items.forEach { (item) in
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
        return items.filter { (item) in
            item.category ?? "" == sectionName
        }
    }

    private func selectItemHavingId(_ id: String) {
        let itemOrNil = itemFromId(id)
        let selectedItem = selectedItemFromId(id)
        guard selectedItem == nil else { return } // already selected
        guard let item = itemOrNil else { return } // no matching item to select
        selectedItems.append(item)
    }
    
    private func deselectItemWithId(_ id: String) {
        selectedItems.removeAll { (item) -> Bool in
            item.id == id
        }
    }
    
    private func itemFromId(_ id: String) -> IdentifiedAndNamed? {
        items.first { (item) -> Bool in
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
