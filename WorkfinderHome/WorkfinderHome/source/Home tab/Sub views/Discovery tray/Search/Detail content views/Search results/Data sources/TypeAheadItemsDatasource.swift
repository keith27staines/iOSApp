
import UIKit

class TypeAheadItemsDatasource: Datasource {
    
    var typeAheadItems = [TypeAheadItem]() {
        didSet {
            data = typeAheadItems
            loadData()
        }
    }
    
    override func loadData() {
        table?.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: TypeAheadCell.reuseIdentifier) as? TypeAheadCell,
            let item = data[indexPath.row] as? TypeAheadItem
        else { return UITableViewCell() }
        cell.updateFrom(item)
        return cell
    }

    override init(
        tag: Int,
        table: UITableView,
        searchResultsController: SearchResultsController
    ) {
        super.init(tag: tag, table: table, searchResultsController: searchResultsController)
        table.register(TypeAheadCell.self, forCellReuseIdentifier: TypeAheadCell.reuseIdentifier)
    }
}
