
import UIKit
import WorkfinderCommon

class TypeAheadItemsDatasource: Datasource, UITableViewDelegate {
    
    var typeAheadItems = [TypeAheadItem]() {
        didSet {
            data = typeAheadItems.map({ (item) -> TypeAheadItem in
                return item.settingAppSource(appSource)
            })
        }
    }
    
    override func loadData(completion: @escaping (Error?) -> Void) {
        table?.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: TypeAheadCell.reuseIdentifier) as? TypeAheadCell,
            let item = data[indexPath.row] as? TypeAheadItem
        else { return UITableViewCell() }
        cell.updateFrom(item)
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = data[indexPath.row]
        NotificationCenter.default.post(name: .wfHomeScreenSearchResultTapped, object: item)

    }

    override init(
        tag: Int,
        table: UITableView,
        searchResultsController: SearchResultsController,
        appSource: AppSource
    ) {
        super.init(tag: tag, table: table, searchResultsController: searchResultsController, appSource: appSource)
        table.register(TypeAheadCell.self, forCellReuseIdentifier: TypeAheadCell.reuseIdentifier)
        table.delegate = self
    }
}
