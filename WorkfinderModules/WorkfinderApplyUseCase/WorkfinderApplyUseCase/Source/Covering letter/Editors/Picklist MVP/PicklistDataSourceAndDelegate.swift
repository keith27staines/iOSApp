import UIKit
import WorkfinderCommon

protocol OtherItemEditorProtocol: AnyObject {
    func edit(_ : PicklistItemJson)
}

class PicklistDataSourceAndDelegate: NSObject, UITableViewDataSource, UITableViewDelegate {
    let picklist: PicklistProtocol
    weak var otherItemEditor: OtherItemEditorProtocol?
    
    init(picklist: PicklistProtocol, tableView: UITableView, otherItemEditor: OtherItemEditorProtocol) {
        self.picklist = picklist
        self.otherItemEditor = otherItemEditor
        tableView.register(StandardPicklistItemTableViewCell.self, forCellReuseIdentifier: "standard")
        tableView.register(OtherPicklistItemTableViewCell.self, forCellReuseIdentifier: "other")
        super.init()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return picklist.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = picklist.items[indexPath.row]
        if item.uuid == "other" {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "other") as? OtherPicklistItemTableViewCell else { return UITableViewCell() }
            cell.configureWith(item, picklist: picklist)
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "standard") as? StandardPicklistItemTableViewCell else {return UITableViewCell() }
            cell.configureWith(item, picklist: picklist)
            return cell
        }
    }
    
    func performSelectionLogic(picklist: PicklistProtocol, tableView: UITableView, indexPath: IndexPath) {
        maxEquals1PicklistSelectionLogic(picklist: picklist, tableView: tableView,indexPath: indexPath)
        maxGreaterThan1PicklistSelectionLogic(picklist: picklist, indexPath: indexPath)
    }
    
    func maxEquals1PicklistSelectionLogic(
        picklist: PicklistProtocol,
        tableView: UITableView,
        indexPath: IndexPath) {
        guard picklist.maximumPicks == 1 else { return }
        let item = picklist.items[indexPath.row]
        guard let previousSelection = picklist.selectedItems.first
            else {
            picklist.selectItem(item)
            return
        }
        picklist.deselectItem(previousSelection)
        guard let row = (picklist.items.firstIndex { (otherItem) -> Bool in
            otherItem.guaranteedUuid == previousSelection.guaranteedUuid
        }) else { return }
        let indexPath = IndexPath(row: row, section: 0)
        tableView.reloadRows(at: [indexPath], with: .automatic)
        if item.guaranteedUuid != previousSelection.guaranteedUuid {
            picklist.selectItem(item)
        }
    }
    
    func maxGreaterThan1PicklistSelectionLogic(
        picklist: PicklistProtocol,
        indexPath: IndexPath) {
        guard picklist.maximumPicks > 1 else
        { return }
        let item = picklist.items[indexPath.row]
        if picklist.selectedItems.contains(where: { (otherItem) -> Bool in
            otherItem.guaranteedUuid == item.guaranteedUuid
        }) {
            picklist.deselectItem(item)
        } else {
            if picklist.selectedItems.count < picklist.maximumPicks { picklist.selectItem(item) }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSelectionLogic(picklist: picklist, tableView: tableView, indexPath: indexPath)
        tableView.reloadRows(at: [indexPath], with: .automatic)
        editItemAtIndexPath(indexPath)
    }
    
    func editItemAtIndexPath(_ indexPath: IndexPath) {
        let item = picklist.items[indexPath.row]
        switch item.guaranteedUuid {
        case "other":
            self.otherItemEditor?.edit(item)
        default: return
        }
    }
}

