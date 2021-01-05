
import UIKit
import WorkfinderCommon

class SearchResultsController {
    var messageHandler: HSUserMessageHandler?
    enum TabName: String, CaseIterable {
        case roles = "Roles"
//        case companies = "Companies"
        case people = "People"
    }
    
    var view: SearchResultsView? {
        didSet {
            guard let view = view else { return }
            messageHandler = HSUserMessageHandler(view: view)
        }
    }
    
    let rolesService: RolesServiceProtocol
    let associationsService: AssociationsServiceProtocol
    let tabNames: [String] = TabName.allCases.map { $0.rawValue }
    var tables: [UITableView] { view?.tableViews ?? [] }
    
    lazy var datasources: [Datasource] = {
        [
            RolesDatasource(
                tag: 0,
                table: tables[0],
                searchResultsController: self,
                service: rolesService,
                appSource: .homeTabSearchResultsProjectsList),
//            CompaniesDatasource(tag: 1, table: tables[1], searchResultsController: self),

            PeopleDatasource(tag: 1, table: tables[1], searchResultsController: self, associationsService: associationsService, appSource: .homeTabSearchResultsPeopleList)
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
            (datasources[1] as? TypeAheadItemsDatasource)?.typeAheadItems = []
            self.messageHandler?.showLoadingOverlay(style: .transparent)
            datasources[1].loadData { [weak self] (error) in
                guard let self = self else { return }
                self.messageHandler?.hideLoadingOverlay()
            }
        }
    }
        
    var queryItems = [URLQueryItem]() {
        didSet {
            datasources.forEach { (datasource) in
                datasource.queryItems = queryItems
            }
            let roleDatasource = datasources[0]
            messageHandler?.showLoadingOverlay(style: .transparent)
            roleDatasource.loadData() { [weak self] error in
                guard let self = self else { return }
                self.messageHandler?.hideLoadingOverlay()
            }
        }
    }
    
    init(
        rolesService: RolesServiceProtocol,
        associationsService: AssociationsServiceProtocol) {
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




