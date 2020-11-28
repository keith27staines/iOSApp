
import UIKit
import WorkfinderUI

enum Section: Int, CaseIterable {
    case searchBar
    case popularOnWorkfinder
    case recommendations
    case topRoles
    case recentRoles
}

class DiscoveryTrayController: NSObject {
    
    lazy var tray: DiscoveryTrayView = DiscoveryTrayView()
    var tableView: UITableView { tray.tableView }
    var sectionPresenters = [Section: CellPresenter]()
    let topRolesBackgroundColor = UIColor.init(white: 247/255, alpha: 1)
    lazy var recentRolesPresenter: RecentRolesDataSource = {
        let datasource = RecentRolesDataSource()
        datasource.reloadRow = { row in
            self.tableView.reloadRows(at: [IndexPath(row: row, section: Section.recentRoles.rawValue)], with: .automatic)
        }
        return datasource
    }()
    
    override init() {
        super.init()
        configureTableView()
        NotificationCenter.default.addObserver(self, selector: #selector(searchEditingDidStart), name: SearchBarCell.didStartEditingSearchFieldNotificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(searchEditingDidEnd), name: SearchBarCell.didEndEditingSearchFieldNotificationName, object: nil)
        recentRolesPresenter.resultHandler = { optionalError in
            self.tableView.reloadSections(IndexSet([Section.recentRoles.rawValue]), with: .automatic)
        }
        recentRolesPresenter.loadData()
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
        tableView.register(SearchBarCell.self, forCellReuseIdentifier: SearchBarCell.identifier)
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
        Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else { return 0 }
        switch section {
        case .searchBar:
            return 1
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
        guard let section = Section(rawValue: indexPath.section) else { return UITableViewCell() }
        let gutter = gutterMargin(fullWidth: tableView.frame.width - 40, cardWidth: 158)
        let cell: UITableViewCell?
        switch section {
        case .searchBar:
            cell = tableView.dequeueReusableCell(withIdentifier: SearchBarCell.identifier) as? SearchBarCell
            cell?.backgroundColor = UIColor.white
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
        guard let section = Section(rawValue: indexPath.section) else { return nil }
        var presenter = sectionPresenters[section]
        if presenter == nil {
            switch section {
            case .searchBar: presenter = SearchBarPresenter()
            case .popularOnWorkfinder: presenter = PopularOnWorkfinderPresenter()
            case .recommendations: presenter = RecommendationsPresenter()
            case .topRoles: presenter = TopRolesPresenter()
            case .recentRoles: presenter = recentRolesPresenter
            }
        }
        sectionPresenters[section] = presenter
        return presenter
    }

}

extension DiscoveryTrayController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let section = Section(rawValue: section) else { return UIView() }
        let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: SectionHeaderView.identifier)
        cell?.backgroundColor = UIColor.white
        cell?.contentView.backgroundColor = UIColor.white
        var text: String = ""
        switch section {
        case .searchBar: break
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
        guard let section = Section(rawValue: section) else { return nil }
        var view: UIView? = tableView.dequeueReusableHeaderFooterView(withIdentifier: SectionFooterView.identifier)
        switch section {
        case .searchBar:
            break
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


