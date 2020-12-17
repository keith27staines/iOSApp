
import WorkfinderCommon
import WorkfinderServices

class PeopleDatasource: TypeAheadItemsDatasource {
    let associationsService: AssociationsServiceProtocol
    
    override func loadData() {
        data = []
        table?.reloadData()
        associationsService.fetchAssociations(queryItems: queryItems) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let xxx):
                self.data = xxx.results.map { (association) -> TypeAheadItem in
                    TypeAheadItem(uuid: association.uuid, title: association.host?.fullName, subtitle: association.title, searchTerm: "", objectType: "association", iconUrlString: association.host?.photoUrlString)
                }
                self.table?.reloadData()
            case .failure(let error):
                self.data = []
                self.table?.reloadData()
                break
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
