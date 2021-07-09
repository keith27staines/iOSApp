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
    var rowCheckManager: RowCheckManager?
    var onUpdate: (() -> Void)?
    
    init(coordinator: AccountCoordinator, service: AccountServiceProtocol, picklist: AccountPicklist, onUpdate: @escaping () -> Void) {
        self.picklist = picklist
        self.onUpdate = onUpdate
        super.init(coordinator: coordinator, accountService: service)
    }
    
    var table: UITableView? {
        didSet {
            guard let table = table else { return }
            rowCheckManager = RowCheckManager(table: table, picklist: picklist)
            let type = picklist.type
            let header = TableHeaderView(for: table, title: type.instruction, showSearchBar: type.showSearchBar)
            table.tableHeaderView = header
            header.searchbar.delegate = self
        }
    }
        
    override func numberOfSections(in tableView: UITableView) -> Int {
        if table == nil { table = tableView }
        return picklist.sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        picklist.numberOfItemsForSection(section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = picklist.itemForIndexPath(indexPath)
        let cell = UITableViewCell()
        cell.textLabel?.text = item.name
        cell.accessoryType = picklist.isItemSelectedAtIndexPath(indexPath) ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        rowCheckManager?.onTap(indexPath: indexPath)
        onUpdate?()
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
        table?.reloadData()
    }
}


/// RowCheckManager encapsulates the logic for checking and unchecking row in the table view
class RowCheckManager {
    
    weak var table: UITableView?
    weak var picklist: AccountPicklist?
    
    init(table: UITableView, picklist: AccountPicklist) {
        self.table = table
        self.picklist = picklist
    }
    
    /// Checks, unchecks or moves the check according to whether the picklist allows multiple selections or not
    func onTap(indexPath: IndexPath) {
        guard
            let table = table,
            let picklist = picklist,
            let tappedId = picklist.itemForIndexPath(indexPath).id,
            let cell = table.cellForRow(at: indexPath)
            else { return }
        
        
        let isCurrentlySelected = picklist.isItemSelectedAtIndexPath(indexPath)
        if isCurrentlySelected {
            _ = picklist.deselectItemWithId(tappedId)
            updateCell(cell, itemId: tappedId, picklist: picklist)
        } else {
            if picklist.type.maxSelections == 1,
               let previousSelectionId = picklist.firstSelectedItem()?.id,
               let previouslySelectedIndexPath = picklist.indexPathForItem(with: previousSelectionId),
               let previouslySelectedCell = table.cellForRow(at: previouslySelectedIndexPath) {
                    _ = picklist.deselectItemWithId(previousSelectionId)
                    updateCell(previouslySelectedCell, itemId: previousSelectionId, picklist: picklist)
            }
            _ = picklist.selectItemHavingId(tappedId)
            updateCell(cell, itemId: tappedId, picklist: picklist)
        }
    }
    
    func updateCell(_ cell: UITableViewCell, itemId: String, picklist: AccountPicklist) {
        let isChecked = picklist.isItemSelected(id: itemId)
        cell.accessoryType = isChecked ? .checkmark : .none
    }
}
