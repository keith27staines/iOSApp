
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
    var sectionPresenters = [DiscoverTraySectionManager.Section: SectionPresenterProtocol]()
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
    
    lazy var featuredOnWorkfinderPresenter: FeaturedOnWorkfinderPresenter = {
        FeaturedOnWorkfinderPresenter(rolesService: rolesService, messageHandler: messageHandler)
    }()
    
    lazy var popularOnWorkfinderPresenter: PopularOnWorkfinderPresenter = {
        PopularOnWorkfinderPresenter(messageHandler: messageHandler)
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
        messageHandler?.showLoadingOverlay(style: .transparent)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
        featuredOnWorkfinderPresenter.load { [weak self] optionalError in
            guard let self = self else { return }
            self.messageHandler?.hideLoadingOverlay()
            self.messageHandler?.displayOptionalErrorIfNotNil(optionalError, retryHandler: self.loadData)
            self.tableView.reloadData()
        }
    }
    
    @objc func handleCandidateSignedIn() {
        tableView.reloadData()
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
        tableView.register(FeaturedOnWorkfinderCell.self, forCellReuseIdentifier: FeaturedOnWorkfinderCell.identifier)
        tableView.register(SectionHeaderView.self, forHeaderFooterViewReuseIdentifier: SectionHeaderView.identifier)
        tableView.register(SectionFooterView.self, forHeaderFooterViewReuseIdentifier: SectionFooterView.identifier)
        tableView.tableFooterView = UIView()
        tableView.refreshControl = nil // refreshControl
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
//        control.addTarget(self, action: #selector(loadFirstPage), for: .valueChanged)
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
        case .featuredOnWorkfinder:
            return featuredOnWorkfinderPresenter.roles.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sectionManager.sectionForSectionIndex(indexPath.section)
        let cell: UITableViewCell?
        switch section {
        case .popularOnWorkfinder:
            cell = tableView.dequeueReusableCell(withIdentifier: PopularOnWorkfinderCell.identifier)
            cell?.backgroundColor = UIColor.white
        case .featuredOnWorkfinder:
            cell = tableView.dequeueReusableCell(withIdentifier: FeaturedOnWorkfinderCell.identifier)
            cell?.backgroundColor = UIColor.white
        }
        let presentable = cell as? PresentableProtocol
        let presenter = cellPresenter(indexPath)
        presentable?.presentWith(presenter, width: tableView.frame.width)
        return cell ?? UITableViewCell()
    }
    
    func gutterMargin(fullWidth: CGFloat, cardWidth: CGFloat) -> CGFloat {
        return (fullWidth - 2 * cardWidth) / 2
    }
    
    func cellPresenter(_ indexPath: IndexPath) -> CellPresenterProtocol? {
        let section = sectionManager.sectionForSectionIndex(indexPath.section)
        var sectionPresenter = sectionPresenters[section]
        if sectionPresenter == nil {
            switch section {
            case .popularOnWorkfinder: sectionPresenter = popularOnWorkfinderPresenter
            case .featuredOnWorkfinder:
                sectionPresenter = featuredOnWorkfinderPresenter
            }
            sectionPresenters[section] = sectionPresenter
            sectionPresenter = sectionPresenters[section]
        }
        return sectionPresenter?.cellPresenterForRow(indexPath.row)
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
        case .featuredOnWorkfinder: text = "Featured Opportunities"
        }
        (cell as? SectionHeaderView)?.sectionTitle.text = text
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }

}



