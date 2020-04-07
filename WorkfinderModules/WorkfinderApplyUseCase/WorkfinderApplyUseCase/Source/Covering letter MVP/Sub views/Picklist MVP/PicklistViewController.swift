
import UIKit

protocol PicklistCoordinator: class {
    
}

class PicklistViewController: UITableViewController {
    
    weak var coordinator: PicklistCoordinator?
    let picklist: Picklist
    
    override func viewDidLoad() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.backgroundColor = UIColor.white
    }
    
    init(coordinator: PicklistCoordinator, picklist: Picklist) {
        self.coordinator = coordinator
        self.picklist = picklist
        super.init(nibName: nil, bundle: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return picklist.items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        let item = picklist.items[indexPath.row]
        cell.textLabel?.text = item.value
        if picklist.selectedItems.contains(where: { (otherItem) -> Bool in
            otherItem.uuid == item.uuid
        }) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = picklist.items[indexPath.row]
        if picklist.selectedItems.contains(where: { (otherItem) -> Bool in
            otherItem.uuid == item.uuid
        }) {
            picklist.deselectItem(item)
        } else {
            if picklist.selectedItems.count < picklist.maximumPicks { picklist.selectItem(item) }
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
