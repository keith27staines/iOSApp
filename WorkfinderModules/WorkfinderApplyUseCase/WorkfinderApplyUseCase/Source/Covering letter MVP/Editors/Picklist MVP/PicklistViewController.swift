
import UIKit
import WorkfinderCommon
import WorkfinderUI

protocol PicklistCoordinatorProtocol: class {
    func picklistIsClosing(_ picklist: PicklistProtocol)
}

class PicklistViewController: UITableViewController {
    
    weak var coordinator: PicklistCoordinatorProtocol?
    let picklist: PicklistProtocol
    var dataSource: PicklistDataSourceAndDelegate!
    
    override func viewDidLoad() {
        navigationItem.title = "Select \(picklist.title)"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.backgroundColor = UIColor.white
        navigationItem.largeTitleDisplayMode = .automatic
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        coordinator?.picklistIsClosing(picklist)
    }
    
    init(coordinator: PicklistCoordinatorProtocol, picklist: PicklistProtocol) {
        self.coordinator = coordinator
        self.picklist = picklist
        super.init(nibName: nil, bundle: nil)
        self.dataSource = PicklistDataSourceAndDelegate(
            picklist: self.picklist,
            tableView: self.tableView)
    }
        
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
