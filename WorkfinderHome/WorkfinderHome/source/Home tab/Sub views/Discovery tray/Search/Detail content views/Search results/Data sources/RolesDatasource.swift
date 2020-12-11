
import WorkfinderServices

class RolesDatasource: Datasource {
    let service: RolesServiceProtocol?
    
    override func loadData() {
        service?.fetchRolesWithQueryItems(queryItems, completion: { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let roleDataArray):
                self.lastError = nil
                self.data = roleDataArray
                self.table?.reloadData()
            case .failure(let error):
                self.lastError = error
                self.data = []
                self.table?.reloadData()
            }
        })
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: RoleSearchResultCell.identifer) as? RoleSearchResultCell,
            let roleData = data[indexPath.row] as? RoleData
        else { return UITableViewCell() }
        cell.presentWith(roleData)
        return cell
    }

    init(
        tag: Int,
        table: UITableView,
        searchResultsController: SearchResultsController,
        service: RolesServiceProtocol
    ) {
        self.service = service
        super.init(tag: tag, table: table, searchResultsController: searchResultsController)
        table.register(RoleSearchResultCell.self, forCellReuseIdentifier: RoleSearchResultCell.identifer)
    }
}

