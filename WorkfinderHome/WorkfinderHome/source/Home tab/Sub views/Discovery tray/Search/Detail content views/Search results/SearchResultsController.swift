
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
    let associationsService: AssociationsServiceProtocol
    let tabNames: [String] = TabName.allCases.map { $0.rawValue }
    var tables: [UITableView] { view?.tableViews ?? [] }
    
    lazy var datasources: [Datasource] = {
        [
            RolesDatasource(tag: 0, table: tables[0], searchResultsController: self, service: rolesService),
            CompaniesDatasource(tag: 1, table: tables[1], searchResultsController: self),
            PeopleDatasource(tag: 2, table: tables[2], searchResultsController: self, associationsService: associationsService)
        ]
    }()
    
    var selectedTabIndex: Int = 0 {
        didSet {
            view?.updateFromController()
        }
    }
    
    func tabTapped(tab: Tab) { selectedTabIndex = tab.index }
    
    var typeAheadJson: TypeAheadJson? {
        didSet {
            (datasources[1] as? TypeAheadItemsDatasource)?.typeAheadItems = typeAheadJson?.companies ?? []
            (datasources[2] as? TypeAheadItemsDatasource)?.typeAheadItems = []
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
    
    init(rolesService: RolesServiceProtocol, associationsService: AssociationsServiceProtocol) {
        self.rolesService = rolesService
        self.associationsService = associationsService
    }
    
}

class RolePresenter: CellPresenter {
    let roleData: RoleData
    init(roleData: RoleData) {
        self.roleData = roleData
    }
}




