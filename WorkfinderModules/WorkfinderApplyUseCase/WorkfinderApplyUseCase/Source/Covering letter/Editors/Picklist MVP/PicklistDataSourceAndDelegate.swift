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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = picklist.items[indexPath.row]
        if picklist.maximumPicks == 1 {
            if let previousSelection = picklist.selectedItems.first {
                picklist.deselectItem(previousSelection)
                let row = picklist.items.firstIndex { (otherItem) -> Bool in
                    otherItem.guaranteedUuid == previousSelection.uuid
                }
                let indexPath = IndexPath(row: row!, section: 0)
                tableView.reloadRows(at: [indexPath], with: .automatic)
                if item.guaranteedUuid != previousSelection.guaranteedUuid {
                    picklist.selectItem(item)
                }
            } else {
                picklist.selectItem(item)
            }
        } else {
            if picklist.selectedItems.contains(where: { (otherItem) -> Bool in
                otherItem.guaranteedUuid == item.guaranteedUuid
            }) {
                picklist.deselectItem(item)
            } else {
                if picklist.selectedItems.count < picklist.maximumPicks { picklist.selectItem(item) }
            }
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
        editItemIfNecessary(item)
    }
    
    func editItemIfNecessary(_ item: PicklistItemJson) {
        switch item.guaranteedUuid {
        case "other":
            self.otherItemEditor?.edit(item)
        default: return
        }
    }
}
