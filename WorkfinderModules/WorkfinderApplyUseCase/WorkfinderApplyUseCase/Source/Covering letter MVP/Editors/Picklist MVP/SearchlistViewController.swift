import UIKit
import WorkfinderCommon
import WorkfinderUI

class SearchlistViewController<A: Codable>: UIViewController, UISearchBarDelegate {
    
    weak var coordinator: PicklistCoordinatorProtocol?
    let picklist: TextSearchPicklistProtocol
    var dataSource: PicklistDataSourceAndDelegate!
    
    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.autocorrectionType = .no
        searchBar.autocapitalizationType = .none
        searchBar.delegate = self
        searchBar.searchBarStyle = .prominent
        searchBar.placeholder = "Start entering name"
        return searchBar
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    
    override func viewDidLoad() {
        navigationItem.title = "Select \(picklist.title)"
        configureViews()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        coordinator?.picklistIsClosing(picklist)
    }
    
    func configureViews() {
        view.backgroundColor = UIColor.white
        view.addSubview(searchBar)
        view.addSubview(tableView)
        let guide = view.safeAreaLayoutGuide
        searchBar.anchor(top: guide.topAnchor,
                         leading: guide.leadingAnchor,
                         bottom: nil, trailing: guide.trailingAnchor)
        tableView.anchor(top: searchBar.bottomAnchor,
                         leading: guide.leadingAnchor,
                         bottom: guide.bottomAnchor,
                         trailing: guide.trailingAnchor)
    }
    
    init(coordinator: PicklistCoordinatorProtocol,
         picklist: TextSearchPicklistProtocol) {
        self.coordinator = coordinator
        self.picklist = picklist
        super.init(nibName: nil, bundle: nil)
        self.dataSource = PicklistDataSourceAndDelegate(
            picklist: self.picklist,
            tableView: self.tableView)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        picklist.clearResults()
        tableView.reloadData()
        picklist.fetchMatches(matchingString: searchText) { [weak self] (result) in
            self?.tableView.reloadData()
        }
    }
    
    required init?(coder: NSCoder)  { fatalError("init(coder:) has not been implemented") }
}
