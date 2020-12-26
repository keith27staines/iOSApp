
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
        configureNavigationBar()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.backgroundColor = UIColor.white
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        guard isMovingFromParent else { return }
       coordinator?.picklistIsClosing(picklist)
    }
    
    func configureNavigationBar() {
        let objectType = picklist.type.title.capitalized
        navigationItem.title = "Select \(objectType)"
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backButton
        styleNavigationController()
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
