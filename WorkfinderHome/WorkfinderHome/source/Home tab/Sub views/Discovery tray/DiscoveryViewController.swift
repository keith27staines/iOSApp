
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
    
    override init() {
        super.init()
        configureTableView()
        NotificationCenter.default.addObserver(self, selector: #selector(searchEditingDidStart), name: SearchBarCell.didStartEditingSearchFieldNotificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(searchEditingDidEnd), name: SearchBarCell.didEndEditingSearchFieldNotificationName, object: nil)
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
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SearchBarCell.self, forCellReuseIdentifier: SearchBarCell.identifier)
        tableView.register(PopularOnWorkfinderCell.self, forCellReuseIdentifier: PopularOnWorkfinderCell.identifier)
        tableView.register(RecommendationsCell.self, forCellReuseIdentifier: RecommendationsCell.identifier)
        tableView.register(TopRolesCell.self, forCellReuseIdentifier: TopRolesCell.identifier)
        tableView.register(RecentRolesView.self, forCellReuseIdentifier: RecentRolesView.identifier)
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
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section) else { return UITableViewCell() }
        let cell: UITableViewCell?
        switch section {
        case .searchBar:
            cell = tableView.dequeueReusableCell(withIdentifier: SearchBarCell.identifier)
        case .popularOnWorkfinder:
            cell = tableView.dequeueReusableCell(withIdentifier: PopularOnWorkfinderCell.identifier)
        case .recommendations:
            cell = tableView.dequeueReusableCell(withIdentifier: RecommendationsCell.identifier)
        case .topRoles:
            cell = tableView.dequeueReusableCell(withIdentifier: TopRolesCell.identifier)
        case .recentRoles:
            cell = tableView.dequeueReusableCell(withIdentifier: RecentRolesView.identifier)
        }
        let presentable = cell as? Presentable
        let presenter = cellPresenter(indexPath)
        presentable?.presentWith(presenter)
        return cell ?? UITableViewCell()
    }
    
    func cellPresenter(_ indexPath: IndexPath) -> CellPresenter? {
        return nil
    }

}

extension DiscoveryTrayController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let section = Section(rawValue: section) else { return UIView() }
        let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: SectionHeaderView.identifier)
        var text: String = ""
        switch section {
        case .searchBar: break
        case .popularOnWorkfinder: text = "Popular on Workfinder"
        case .recommendations: text = "Recommendations"
        case .topRoles: text = "Top roles"
        case .recentRoles: text = "Recent roles"
        }
        (cell as? SectionHeaderView)?.sectionTitle.text = text
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let section = Section(rawValue: section) else { return nil }
        switch section {
        case .searchBar:
            return tableView.dequeueReusableHeaderFooterView(withIdentifier: SectionFooterView.identifier)
        default:
            return tableView.dequeueReusableHeaderFooterView(withIdentifier: SectionFooterView.identifier)
        }
    }
}

protocol CellPresenter {}

protocol Presentable {
    func presentWith(_ presenter: CellPresenter?)
}


class RecentRolesView: UITableViewCell, Presentable {
    static let identifier = "RecentRolesView"
    func presentWith(_ presenter: CellPresenter?) {
        
    }
}


