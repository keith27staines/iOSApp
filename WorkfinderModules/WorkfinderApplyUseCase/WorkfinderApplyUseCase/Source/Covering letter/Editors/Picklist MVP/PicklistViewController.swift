
import UIKit
import WorkfinderCommon
import WorkfinderCoordinators
import WorkfinderUI

protocol PicklistCoordinatorProtocol: CoreInjectionNavigationCoordinatorProtocol {
    func picklistIsClosing(_ picklist: PicklistProtocol)
}

class PicklistViewController: UITableViewController {
    
    weak var coordinator: PicklistCoordinatorProtocol?
    let picklist: PicklistProtocol
    var dataSource: PicklistDataSourceAndDelegate!
    
    override func viewDidLoad() {
        navigationItem.title = "Select \(picklist.type.title)"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.backgroundColor = UIColor.white
        navigationItem.largeTitleDisplayMode = .automatic
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if isMovingFromParent {
            coordinator?.picklistIsClosing(picklist)
        }
    }
    
    init(coordinator: PicklistCoordinatorProtocol, picklist: PicklistProtocol) {
        self.coordinator = coordinator
        self.picklist = picklist
        super.init(nibName: nil, bundle: nil)
        self.dataSource = PicklistDataSourceAndDelegate(
            picklist: self.picklist,
            tableView: self.tableView,
            otherItemEditor: self)
    }
        
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

extension PicklistViewController: OtherItemEditorProtocol {
    func edit(_ item: PicklistItemJson) {
        let vc = OtherPicklistItemEditorViewController(
            coordinator: self,
            picklistItem: item,
            type: picklist.type)
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension PicklistViewController: TextEditorCoordinatorProtocol {
    func textEditorIsClosing(text: String) {
        picklist.updateSelectedTextValue(text.trimmingCharacters(in: .whitespacesAndNewlines))
        tableView.reloadData()
    }
}
