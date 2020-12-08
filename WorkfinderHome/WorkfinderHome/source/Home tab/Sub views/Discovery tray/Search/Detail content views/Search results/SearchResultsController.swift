
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
        [Datasource(tag: 0, dataLoader: dataLoaders[0], table: tables[0])]
    }()
    
    lazy var dataLoaders: [DataLoader] = {
        [RolesDataLoader(service: rolesService)]
    }()
    
    var selectedTabIndex: Int = 0 {
        didSet {
            view?.updateFromController()
        }
    }
    
    func tabTapped(tab: Tab) { selectedTabIndex = tab.index }
    
    var queryString: String? {
        didSet {
            print("searching... [\(queryString ?? "No search string")]")
            datasources[selectedTabIndex].loadData()
        }
    }
    
    init(rolesService: RolesServiceProtocol) {
        self.rolesService = rolesService
    }
    
}

protocol DataLoader {
    func fetch<A:Codable>(completion: (Result<[A], Error>) -> Void)
}

class RolesDataLoader: DataLoader {
    var query = ""
    let service: RolesServiceProtocol
    func fetch<A:Codable>(completion: (Result<[A], Error>) -> Void) {
        //service.fetchRolesWithQuery(query, completion: <#T##(Result<[RoleData], Error>) -> Void#>)
    }
    
    init(service: RolesServiceProtocol) {
        self.service = service
    }
}

class Datasource: NSObject, UITableViewDataSource {

    weak var table: UITableView?
    let dataLoader: DataLoader
    var data = [String]()
    let tag: Int
        
    func loadData() {
//        dataLoader.fetch { [weak self] (result) in
//            self?.data = ["Apple", "Banana", "Orange"]
//            self?.table?.reloadData()
//        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int { 1 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        UITableViewCell()
    }
    
    init(tag: Int, dataLoader: DataLoader, table: UITableView) {
        self.tag = tag
        self.dataLoader = dataLoader
        self.table = table
        super.init()
    }
}

