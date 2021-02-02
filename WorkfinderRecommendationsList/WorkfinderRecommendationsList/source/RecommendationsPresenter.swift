
import WorkfinderCommon
import WorkfinderServices

class RecommendationsPresenter {
    weak var coordinator: RecommendationsCoordinator?
    let service: RecommendationsServiceProtocol
    var recommendations = [RecommendationsListItem]()
    var tilePresenters = [RecommendationTilePresenter]()
    let userRepo: UserRepositoryProtocol
    var workplaceServiceFactory: (() -> ApplicationContextService)?
    var hostServiceFactory: (() -> HostsProviderProtocol)?
    var projectServiceFactory: (() -> ProjectServiceProtocol)?
    
    var count: Int = 0
    var nextPage: String?
    
    init(coordinator: RecommendationsCoordinator,
         service: RecommendationsServiceProtocol,
         userRepo:UserRepositoryProtocol,
         workplaceServiceFactory: @escaping (() -> ApplicationContextService),
         projectServiceFactory: @escaping (() -> ProjectServiceProtocol),
         hostServiceFactory: @escaping (() -> HostsProviderProtocol)) {
        self.coordinator = coordinator
        self.service = service
        self.userRepo = userRepo
        self.workplaceServiceFactory = workplaceServiceFactory
        self.projectServiceFactory = projectServiceFactory
        self.hostServiceFactory = hostServiceFactory
    }
    
    weak var view: RecommendationsViewController?
    
    var noRecommendationsYet: Bool {
        recommendations.count == 0 ? true : false
    }
    
    func onViewDidLoad(view: RecommendationsViewController) {
        self.view = view
    }
    
    func refreshRow(_ row: Int) {
        view?.reloadRow([IndexPath(row: row, section: 0)])
    }
    
    func loadFirstPage(completion: @escaping (Error?) -> Void) {
        guard let _ = userRepo.loadAccessToken()
            else {
                completion(nil)
                return
        }
        service.fetchRecommendations() { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let serverList):
                self.count = serverList.count ?? 0
                self.nextPage = serverList.next
                self.recommendations = serverList.results
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    var isLoading = false
    var triggerRow: Int { recommendations.count - 40 / 2}
    
    func loadNextPage(tableView: UITableView) {
        guard let nextPage = nextPage, recommendations.count < count, isLoading == false else { return }
        isLoading = true
        service.fetchNextPage(urlString: nextPage) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let serverList):
                self.count = serverList.count ?? 0
                self.nextPage = serverList.next
                let currentCount = self.recommendations.count
                let addedIndexPaths = IndexSet(integersIn:
                    currentCount..<currentCount+serverList.results.count).map {
                    IndexPath(row: $0, section: 0)
                }
                self.recommendations += serverList.results
                tableView.insertRows(at: addedIndexPaths, with: .bottom)
            case .failure(_): break
            }
            self.isLoading = false
        }
    }
    
    func numberOfSections() -> Int { 1 }
    func numberOfRowsForSection(_ section: Int) -> Int { recommendations.count }

    func recommendationTilePresenterForIndexPath(_ indexPath: IndexPath) -> RecommendationTilePresenterProtocol {
        let row = indexPath.row
        let recommendation = recommendations[row]
        if indexPath.row < tilePresenters.count {
            return tilePresenters[row]
        }
        let workplaceService = workplaceServiceFactory?()
        let projectService = projectServiceFactory?()
        let hostService = hostServiceFactory?()
        let presenter = RecommendationTilePresenter(
            parent: self,
            recommendation: recommendation,
            workplaceService: workplaceService,
            projectService: projectService,
            hostService: hostService,
            row: row)
        tilePresenters.append(presenter)
        return presenter
    }
    
    func onTileTapped(_ tile: RecommendationTilePresenter) {
        
        if tile.isProject {
            coordinator?.processProjectViewRequest(
                tile.recommendation.project?.uuid,
                appSource: .recommendationsTab)
        } else {
            #warning("incomplete implementation")
            // guard let uuid = tile.recommendation.uuid else { return }
            // coordinator?.onRecommendationForAssociationSelected?(uuid)
        }
    }
    
}
