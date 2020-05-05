import UIKit
import WorkfinderCommon

class PicklistDataSourceAndDelegate: NSObject, UITableViewDataSource, UITableViewDelegate {
    let picklist: PicklistProtocol
    
    init(picklist: PicklistProtocol, tableView: UITableView) {
        self.picklist = picklist
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        let item = picklist.items[indexPath.row]
        cell.textLabel?.text = item.value ?? item.name
        if picklist.selectedItems.contains(where: { (otherItem) -> Bool in
            otherItem.guaranteedUuid == item.guaranteedUuid
        }) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
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
    }
}

