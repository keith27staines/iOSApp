
import UIKit
import WorkfinderUI

class DiscoveryTrayController: NSObject {
    
    lazy var tray: DiscoveryTrayView = DiscoveryTrayView()
    var tableView: UITableView { tray.tableView }
    var sectionPresenters = [DiscoverTraySectionManager.Section: CellPresenter]()
    let topRolesBackgroundColor = UIColor.init(white: 247/255, alpha: 1)
    let sectionManager = DiscoverTraySectionManager()
    
    lazy var recentRolesPresenter: RecentRolesDataSource = {
        RecentRolesDataSource(rolesService: rolesService)
    }()
    
    lazy var topRolesPresenter: TopRolesPresenter = {
        TopRolesPresenter(rolesService: rolesService)
    }()
    
    lazy var popularOnWorkfinderPresenter: PopularOnWorkfinderPresenter = {
        PopularOnWorkfinderPresenter()
    }()
    
    lazy var recommendationsPresenter: RecommendationsPresenter = {
        RecommendationsPresenter(rolesService: rolesService)
    }()
    
    let rolesService: RolesServiceProtocol
    
    init(rolesService: RolesServiceProtocol) {
        self.rolesService = rolesService
        super.init()
        configureTableView()
        NotificationCenter.default.addObserver(self, selector: #selector(searchEditingDidStart), name: DiscoveryTrayView.didStartEditingSearchFieldNotificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(searchEditingDidEnd), name: DiscoveryTrayView.didEndEditingSearchFieldNotificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleCandidateSignedIn), name: NSNotification.Name.wfDidLoginCandidate, object: nil)
        recentRolesPresenter.resultHandler = { optionalError in
            guard let sectionIndex = self.sectionManager.sectionIndexForSection(.recentRoles) else { return }
            self.tableView.reloadSections(IndexSet([sectionIndex]), with: .automatic)
        }
        recentRolesPresenter.loadData()
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
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(PopularOnWorkfinderCell.self, forCellReuseIdentifier: PopularOnWorkfinderCell.identifier)
        tableView.register(RecommendationsCell.self, forCellReuseIdentifier: RecommendationsCell.identifier)
        tableView.register(TopRolesCell.self, forCellReuseIdentifier: TopRolesCell.identifier)
        tableView.register(LandscapeRoleCell.self, forCellReuseIdentifier: LandscapeRoleCell.identifer)
        tableView.register(SectionHeaderView.self, forHeaderFooterViewReuseIdentifier: SectionHeaderView.identifier)
        tableView.register(SectionFooterView.self, forHeaderFooterViewReuseIdentifier: SectionFooterView.identifier)
    }
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


