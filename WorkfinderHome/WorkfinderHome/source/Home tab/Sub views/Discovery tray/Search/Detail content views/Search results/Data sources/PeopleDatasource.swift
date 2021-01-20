
import WorkfinderCommon
import WorkfinderServices

class PeopleDatasource: TypeAheadItemsDatasource {
    let associationsService: AssociationsServiceProtocol
    
    override func loadData(completion: @escaping (Error?) -> Void) {
        count = 0
        nextPageUrl = nil
        data = []
        table?.reloadData()
        associationsService.fetchAssociations(queryItems: queryItems) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let serverListJson):
                self.count = serverListJson.count ?? 0
                self.nextPageUrl = serverListJson.next
                self.data = serverListJson.results.map { (association) -> TypeAheadItem in
                    TypeAheadItem(uuid: association.uuid, title: association.host?.fullName, subtitle: association.title, searchTerm: "", objectType: "association", iconUrlString: association.host?.photoUrlString, appSource: self.appSource)
                }
                self.table?.reloadData()
                completion(nil)
            case .failure(let error):
                self.handleDataLoadError(error, retry: { self.loadData(completion: completion) }, completion: completion)
            }
        }
    }
    var loadingURL: String?
    override func loadNextPage() {
        guard let nextPageUrl = nextPageUrl, nextPageUrl != loadingURL else { return }
        loadingURL = nextPageUrl
        associationsService.fetchAssociationsWithUrl(nextPageUrl) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let serverListJson):
                self.nextPageUrl = serverListJson.next
                let lower = self.data.count
                let upper = lower + serverListJson.results.count - 1
                let changeSet = Array(lower ... upper).map { (index) -> IndexPath in
                    IndexPath(row: index, section: 0)
                }
                self.data += serverListJson.results.map { (association) -> TypeAheadItem in
                    TypeAheadItem(uuid: association.uuid, title: association.host?.fullName, subtitle: association.title, searchTerm: "", objectType: "association", iconUrlString: association.host?.photoUrlString, appSource: self.appSource)
                }
                self.table?.insertRows(at:changeSet, with: .automatic)
            case .failure(_): break
            }
            self.loadingURL = nil
        }
    }
    
    init(
        tag: Int,
        table: UITableView,
        searchResultsController: SearchResultsController,
        associationsService: AssociationsServiceProtocol,
        appSource: AppSource
    ) {
        self.associationsService = associationsService
        super.init(tag: tag, table: table, searchResultsController: searchResultsController, appSource: appSource)
    }
}
