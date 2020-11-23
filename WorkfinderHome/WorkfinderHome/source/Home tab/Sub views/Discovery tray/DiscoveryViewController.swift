
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
    }
    
    func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SearchFieldView.self, forCellReuseIdentifier: SearchFieldView.identifier)
        tableView.register(PopularOnWorkfinderView.self, forCellReuseIdentifier: SearchFieldView.identifier)
        tableView.register(RecommendationsView.self, forCellReuseIdentifier: SearchFieldView.identifier)
        tableView.register(TopRolesView.self, forCellReuseIdentifier: SearchFieldView.identifier)
        tableView.register(RecentRolesView.self, forCellReuseIdentifier: SearchFieldView.identifier)
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
        switch section {
        case .searchBar:
            return tableView.dequeueReusableCell(withIdentifier: SearchFieldView.identifier)
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

}

extension DiscoveryTrayController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        false
    }
    
}

class SearchFieldView: UITableViewCell {
    static let identifier = "SearchFieldView"
}

class PopularOnWorkfinderView: UITableViewCell {
    static let identifier = "PopularOnWorkfinderView"
}

class RecommendationsView: UITableViewCell {
    static let identifier = "RecommendationsView"
}

class TopRolesView: UITableViewCell {
    static let identifier = "TopRolesView"
}

class RecentRolesView: UITableViewCell {
    static let identifier = "RecentRolesView"
}

class SectionHeaderView: UITableViewHeaderFooterView {
    static let identifier = "SectionHeaderView"
}

class SectionFooterView: UITableViewHeaderFooterView {
    static let identifier = "SectionFooterView"
}
