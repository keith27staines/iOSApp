
import UIKit
import WorkfinderCommon

class SearchResultsController {
    enum TabName: String, CaseIterable {
        case roles = "Roles"
        case companies = "Companies"
        case people = "People"
    }
    
    var view: SearchResultsView?
    let rolesService: RolesServiceProtocol
    let tabNames: [String] = TabName.allCases.map { $0.rawValue }
    var tables: [UITableView] { view?.tableViews ?? [] }
    
    lazy var datasources: [Datasource] = {
        [RolesDatasource(tag: 0, table: tables[0], searchResultsController: self, service: rolesService)]
    }()
    
    var selectedTabIndex: Int = 0 {
        didSet {
            view?.updateFromController()
        }
    }
    
    func tabTapped(tab: Tab) { selectedTabIndex = tab.index }
        
    var queryItems = [URLQueryItem]() {
        didSet {
            datasources.forEach { (datasource) in
                datasource.queryItems = queryItems
            }
            datasources[selectedTabIndex].loadData()
        }
    }
    
    init(rolesService: RolesServiceProtocol) {
        self.rolesService = rolesService
    }
    
}

class RolePresenter: CellPresenter {
    let roleData: RoleData
    init(roleData: RoleData) {
        self.roleData = roleData
    }
}

class RolesDatasource: Datasource {
    let service: RolesServiceProtocol?
    
    override func loadData() {
        service?.fetchRolesWithQueryItems(queryItems, completion: { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let roleDataArray):
                self.lastError = nil
                self.data = roleDataArray
                self.table?.reloadData()
            case .failure(let error):
                self.lastError = error
                self.data = []
                self.table?.reloadData()
            }
        })
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: RoleSearchResultCell.identifer) as? RoleSearchResultCell,
            let roleData = data[indexPath.row] as? RoleData
        else { return UITableViewCell() }
        cell.presentWith(roleData)
        return cell
    }

    init(
        tag: Int,
        table: UITableView,
        searchResultsController: SearchResultsController,
        service: RolesServiceProtocol
    ) {
        self.service = service
        super.init(tag: tag, table: table, searchResultsController: searchResultsController)
        table.register(RoleSearchResultCell.self, forCellReuseIdentifier: RoleSearchResultCell.identifer)
    }
}

class Datasource: NSObject, UITableViewDataSource {
    weak var searchResultsController: SearchResultsController?
    var lastError: Error?
    var queryItems = [URLQueryItem]()
    weak var table: UITableView?
    var data = [Any]()
    let tag: Int
    
    func numberOfSections(in tableView: UITableView) -> Int { 1 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }
    
    /// override this method
    func loadData() {}
    
    /// override this method
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    init(tag: Int, table: UITableView, searchResultsController: SearchResultsController) {
        self.tag = tag
        self.table = table
        self.searchResultsController = searchResultsController
        super.init()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.dataSource = self
    }
    
}

