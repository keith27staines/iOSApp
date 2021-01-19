import WorkfinderCommon
import WorkfinderServices
import WorkfinderUI

class RolesDatasource: Datasource, UITableViewDelegate {
    
    let service: RolesServiceProtocol?
    var nextPageUrl: String?
    let pageSize: Int = 40
    
    override func loadData(completion: @escaping (Error?) -> Void) {
        data = []
        count = 0
        nextPageUrl = nil
        queryItems.append(URLQueryItem(name: "limit", value: String(pageSize)))
        service?.fetchRolesWithQueryItems(queryItems, completion: { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let serverList):
                self.nextPageUrl = serverList.next
                self.data = serverList.results.settingAppSource(self.appSource)
                self.count = serverList.count ?? 0
                self.table?.reloadData()
                completion(nil)
            case .failure(let error):
                self.handleDataLoadError(error, retry: { self.loadData(completion: completion)}, completion: completion)
            }
        })
    }
    
    func loadNextPage(completion: @escaping () -> Void) {
        guard let nextPageUrl = nextPageUrl else { return }
        service?.fetchRolesWithUrl(urlString: nextPageUrl) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let serverList):
                self.nextPageUrl = serverList.next
                self.data += serverList.results.settingAppSource(self.appSource)
                self.table?.reloadData()
                completion()
            case .failure(_): break
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: RoleSearchResultCell.identifer) as? RoleSearchResultCell,
            let roleData = data[indexPath.row] as? RoleData
        else { return UITableViewCell() }
        cell.presentWith(roleData)
        cell.accessoryType = .disclosureIndicator
        cell.tintColor = WorkfinderColors.primaryColor
        if indexPath.row > data.count - pageSize / 3 {
            loadNextPage {}
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        table?.deselectRow(at: indexPath, animated: true)
        let roleData = data[indexPath.row]
        NotificationCenter.default.post(name: .wfHomeScreenRoleTapped, object: roleData)
    }

    init(
        tag: Int,
        table: UITableView,
        searchResultsController: SearchResultsController,
        service: RolesServiceProtocol,
        appSource: AppSource
    ) {
        self.service = service
        super.init(tag: tag, table: table, searchResultsController: searchResultsController, appSource: appSource)
        table.register(RoleSearchResultCell.self, forCellReuseIdentifier: RoleSearchResultCell.identifer)
        table.delegate = self
    }
}

