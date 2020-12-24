
import UIKit
import WorkfinderUI

class DiscoveryTrayController: NSObject {
    weak var coordinator: HomeCoordinator?
    let rolesService: RolesServiceProtocol
    let typeAheadService: TypeAheadServiceProtocol
    let projectTypesService: ProjectTypesServiceProtocol
    let employmentTypesService: EmploymentTypesServiceProtocol
    let skillTypesService: SkillAcquiredTypesServiceProtocol
    let searchResultsController: SearchResultsController
    
    lazy var tray: DiscoveryTrayView = DiscoveryTrayView(searchBarStack: searchBarStack, searchDetail: searchDetail)
    var tableView: UITableView { tray.tableView }
    var sectionPresenters = [DiscoverTraySectionManager.Section: CellPresenter]()
    let topRolesBackgroundColor = UIColor.init(white: 247/255, alpha: 1)
    let sectionManager = DiscoverTraySectionManager()
    weak var messageHandler: HSUserMessageHandler?
    
    lazy var searchController: SearchController = {
        let filtersModel = FiltersModel(
            projectTypesService: projectTypesService,
            employmentTypesService: employmentTypesService,
            skillTypeService: skillTypesService
        )
        let controller = SearchController(
            coordinator: coordinator,
            log: coordinator?.injected.log,
            typeAheadService: typeAheadService,
            filtersModel: filtersModel,
            searchResultsController: searchResultsController
        )
        controller.state = .hidden
        return controller
    }()
    
    lazy var recentRolesPresenter: RecentRolesDataSource = {
        RecentRolesDataSource(rolesService: rolesService, messageHandler: messageHandler)
    }()
    
    lazy var topRolesPresenter: TopRolesPresenter = {
        TopRolesPresenter(rolesService: rolesService, messageHandler: messageHandler)
    }()
    
    lazy var popularOnWorkfinderPresenter: PopularOnWorkfinderPresenter = {
        PopularOnWorkfinderPresenter(messageHandler: messageHandler)
    }()
    
    lazy var recommendationsPresenter: RecommendationsPresenter = {
        RecommendationsPresenter(rolesService: rolesService, messageHandler: messageHandler)
    }()
    
    var searchBarStack: UIStackView { searchController.searchBarStack }
    var searchDetail: SearchDetailView { searchController.searchDetail }
    
    init(coordinator: HomeCoordinator?,
         rolesService: RolesServiceProtocol,
         typeAheadService: TypeAheadServiceProtocol,
         projectTypesService: ProjectTypesServiceProtocol,
         employmentTypesService: EmploymentTypesServiceProtocol,
         skillTypesService: SkillAcquiredTypesServiceProtocol,
         searchResultsController: SearchResultsController,
         messageHandler: HSUserMessageHandler?
    ) {
        self.coordinator = coordinator
        self.rolesService = rolesService
        self.typeAheadService = typeAheadService
        self.projectTypesService = projectTypesService
        self.employmentTypesService = employmentTypesService
        self.skillTypesService = skillTypesService
        self.searchResultsController = searchResultsController
        self.messageHandler = messageHandler
        super.init()
        configureTableView()
        NotificationCenter.default.addObserver(self, selector: #selector(handleCandidateSignedIn), name: NSNotification.Name.wfDidLoginCandidate, object: nil)
    }
    
    @objc func loadData() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
        recentRolesPresenter.resultHandler = { optionalError in
            guard let sectionIndex = self.sectionManager.sectionIndexForSection(.recentRoles) else { return }
            self.tableView.reloadSections(IndexSet([sectionIndex]), with: .automatic)
        }
        recentRolesPresenter.loadData { [weak self] in
            self?.refreshControl.endRefreshing()
        }
    }
    
    @objc func handleCandidateSignedIn() {
        guard sectionManager.isSignedIn, let recommendationsSectionIndex = sectionManager.sectionIndexForSection(.recommendations)
        else { return }
        let indexSet = IndexSet([recommendationsSectionIndex])
        tableView.performBatchUpdates({
            tableView.insertSections(indexSet, with: .none)
        }) { (update) in
            print("Update SUccess")
        }
    }
    
    @objc func searchEditingDidStart() {
        layoutTable()
    }
    
    @objc func searchEditingDidEnd() {
       layoutTable()
    }
    
    func layoutTable() {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func configureTableView() {
        tableView.allowsSelection = false
        tableView.register(PopularOnWorkfinderCell.self, forCellReuseIdentifier: PopularOnWorkfinderCell.identifier)
        tableView.register(RecommendationsCell.self, forCellReuseIdentifier: RecommendationsCell.identifier)
        tableView.register(TopRolesCell.self, forCellReuseIdentifier: TopRolesCell.identifier)
        tableView.register(LandscapeRoleCell.self, forCellReuseIdentifier: LandscapeRoleCell.identifer)
        tableView.register(SectionHeaderView.self, forHeaderFooterViewReuseIdentifier: SectionHeaderView.identifier)
        tableView.register(SectionFooterView.self, forHeaderFooterViewReuseIdentifier: SectionFooterView.identifier)
        tableView.tableFooterView = UIView()
        tableView.refreshControl = refreshControl
    }
    
    lazy var refreshControl: UIRefreshControl = {
        let title = NSLocalizedString("Pull to refresh", comment: "Pull to refresh")
        let font = UIFont.systemFont(ofSize: 20)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: WorkfinderColors.primaryColor,
        ]
        let control = UIRefreshControl()
        control.attributedTitle = NSAttributedString(string: title, attributes: attributes)
        control.addTarget(self, action: #selector(loadData), for: .valueChanged)
        control.tintColor = WorkfinderColors.primaryColor
        control.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        return control
    }()
}

extension DiscoveryTrayController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        sectionManager.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = sectionManager.sectionForSectionIndex(section)
        switch section {
        case .popularOnWorkfinder:
            return 1
        case .recommendations:
            return 1
        case .topRoles:
            return 1
        case .recentRoles:
            return recentRolesPresenter.numberOfRows
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sectionManager.sectionForSectionIndex(indexPath.section)
        let gutter = gutterMargin(fullWidth: tableView.frame.width - 40, cardWidth: 158)
        let cell: UITableViewCell?
        switch section {
        case .popularOnWorkfinder:
            cell = tableView.dequeueReusableCell(withIdentifier: PopularOnWorkfinderCell.identifier)
            cell?.backgroundColor = UIColor.white
        case .recommendations:
            cell = tableView.dequeueReusableCell(withIdentifier: RecommendationsCell.identifier)
            cell?.backgroundColor = UIColor.white
            (cell as? HorizontallyScrollingCell)?.adjustMarginsAndGetter(verticalMargin: 20, scrollViewHeight: 262, gutter: gutter)
        case .topRoles:
            cell = tableView.dequeueReusableCell(withIdentifier: TopRolesCell.identifier)
            cell?.backgroundColor = topRolesBackgroundColor
            (cell as? HorizontallyScrollingCell)?.adjustMarginsAndGetter(verticalMargin: 20, scrollViewHeight: 262, gutter: gutter)
        case .recentRoles:
            cell = tableView.dequeueReusableCell(withIdentifier: LandscapeRoleCell.identifer)
            cell?.backgroundColor = UIColor.white
            (cell as? LandscapeRoleCell)?.row = indexPath.row
        }
        let presentable = cell as? Presentable
        let presenter = cellPresenter(indexPath)
        presentable?.presentWith(presenter)
        return cell ?? UITableViewCell()
    }
    
    func gutterMargin(fullWidth: CGFloat, cardWidth: CGFloat) -> CGFloat {
        return (fullWidth - 2 * cardWidth) / 2
    }
    
    func cellPresenter(_ indexPath: IndexPath) -> CellPresenter? {
        let section = sectionManager.sectionForSectionIndex(indexPath.section)
        var presenter = sectionPresenters[section]
        if presenter == nil {
            switch section {
            case .popularOnWorkfinder: presenter = popularOnWorkfinderPresenter
            case .recommendations: presenter = recommendationsPresenter
            case .topRoles: presenter = topRolesPresenter
            case .recentRoles: presenter = recentRolesPresenter
            }
        }
        sectionPresenters[section] = presenter
        return presenter
    }

}

extension DiscoveryTrayController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let section = sectionManager.sectionForSectionIndex(section)
        let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: SectionHeaderView.identifier)
        cell?.backgroundColor = UIColor.white
        cell?.contentView.backgroundColor = UIColor.white
        var text: String = ""
        switch section {
        case .popularOnWorkfinder: text = "Popular on Workfinder"
        case .recommendations: text = "Recommendations"
        case .topRoles:
            text = "Top roles"
            cell?.contentView.backgroundColor = topRolesBackgroundColor
        case .recentRoles: text = "Recent roles"
        }
        (cell as? SectionHeaderView)?.sectionTitle.text = text
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let section = sectionManager.sectionForSectionIndex(section)
        var view: UIView? = tableView.dequeueReusableHeaderFooterView(withIdentifier: SectionFooterView.identifier)
        switch section {
        case .recommendations:
            (view as? SectionFooterView)?.isLineHidden = true
        case .popularOnWorkfinder:
            (view as? SectionFooterView)?.isLineHidden = true
        case .topRoles:
            view = UIView()
            view?.backgroundColor = topRolesBackgroundColor
        case .recentRoles:
            view = UIView()
            view?.backgroundColor = UIColor.white
        }
        return view
    }
}

protocol CellPresenter {}

protocol Presentable {
    func presentWith(_ presenter: CellPresenter?)
}


