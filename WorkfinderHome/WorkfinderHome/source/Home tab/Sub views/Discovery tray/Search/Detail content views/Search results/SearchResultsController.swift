
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
    
    var typeAheadJson: TypeAheadJson? {
        didSet {
            
        }
    }
        
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




