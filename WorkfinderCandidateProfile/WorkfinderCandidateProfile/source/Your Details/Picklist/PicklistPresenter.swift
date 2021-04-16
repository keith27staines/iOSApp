//
//  PicklistPresenter.swift
//  WorkfinderCandidateProfile
//
//  Created by Keith Staines on 14/04/2021.
//

import Foundation
import WorkfinderCommon
import WorkfinderServices


class PicklistPresenter: BaseAccountPresenter {

    let picklist: AccountPicklist
    
    init(coordinator: AccountCoordinator, service: AccountServiceProtocol, picklist: AccountPicklist) {
        self.picklist = picklist
        super.init(coordinator: coordinator, accountService: service)
    }
    
    var table: UITableView? {
        didSet {
            guard let table = table else { return }
            let type = picklist.type
            let header = TableHeaderView(for: table, title: type.instruction, showSearchBar: type.showSearchBar)
            table.tableHeaderView = header
            header.searchbar.delegate = self
        }
    }
        
    override func numberOfSections(in tableView: UITableView) -> Int {
        table = tableView
        return picklist.sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        picklist.numberOfItemsForSection(section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = picklist.itemForIndexPath(indexPath)
        let cell = UITableViewCell()
        cell.textLabel?.text = item.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let tappedId = picklist.itemForIndexPath(indexPath).id else { return }
        let cell = tableView.cellForRow(at: indexPath)
        let isCurrentlySelected = picklist.isItemSelectedAtIndexPath(indexPath)
        if isCurrentlySelected {
            if picklist.deselectItemWithId(tappedId) {
                cell?.accessoryType = .none
            }
        } else {
            if picklist.type.maxSelections == 1 {
                if let currentSelectionId = picklist.firstSelectedItem()?.id {
                    let didDeselect = picklist.deselectItemWithId(currentSelectionId)
                    if didDeselect {
                        if let currentSelectionIndexPath = picklist.indexPathForItem(with: currentSelectionId) {
                            let cell = tableView.cellForRow(at: currentSelectionIndexPath)
                            cell?.accessoryType = .none
                        }
                    }
                }
                if picklist.selectItemHavingId(tappedId) {
                    cell?.accessoryType = .checkmark
                }
                
            } else {
                if picklist.selectItemHavingId(tappedId) {
                    cell?.accessoryType = .checkmark
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        picklist.sections[section]
    }
    
    override func reloadPresenter(completion: @escaping (Error?) -> Void) {
        picklist.reload(completion: completion)
    }
}

extension PicklistPresenter: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        picklist.applyFilter(filter: searchText)
        let indexSet = IndexSet(integersIn: 0..<picklist.sections.count)
        table?.reloadSections(indexSet, with: .none)
    }
}
