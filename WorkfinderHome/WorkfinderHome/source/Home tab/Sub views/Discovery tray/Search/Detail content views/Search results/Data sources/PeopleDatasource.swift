
import WorkfinderCommon
import WorkfinderServices

class PeopleDatasource: TypeAheadItemsDatasource {
    let associationsService: AssociationsServiceProtocol
    
    override func loadData(completion: @escaping (Error?) -> Void) {
        data = []
        table?.reloadData()
        associationsService.fetchAssociations(queryItems: queryItems) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let hostAssociationsListItem):
                self.data = hostAssociationsListItem.results.map { (association) -> TypeAheadItem in
                    TypeAheadItem(uuid: association.uuid, title: association.host?.fullName, subtitle: association.title, searchTerm: "", objectType: "association", iconUrlString: association.host?.photoUrlString)
                }
                self.table?.reloadData()
                completion(nil)
            case .failure(let error):
                self.handleDataLoadError(error, retry: { self.loadData(completion: completion) }, completion: completion)
            }
        }
    }
    
    init(
        tag: Int,
        table: UITableView,
        searchResultsController: SearchResultsController,
        associationsService: AssociationsServiceProtocol
    ) {
        self.associationsService = associationsService
        super.init(tag: tag, table: table, searchResultsController: searchResultsController)
    }
}
