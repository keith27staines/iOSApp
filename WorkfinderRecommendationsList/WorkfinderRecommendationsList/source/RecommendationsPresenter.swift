
import WorkfinderCommon
import WorkfinderServices

class RecommendationsPresenter {
    weak var coordinator: RecommendationsCoordinator?
    let service: RecommendationsServiceProtocol
    var recommendations = [Recommendation]()
    var tilePresenters = [RecommendationTilePresenter]()
    let userRepo: UserRepositoryProtocol
    var workplaceServiceFactory: (() -> WorkplaceAndAssociationService)?
    var hostServiceFactory: (() -> HostsProviderProtocol)?
    
    init(coordinator: RecommendationsCoordinator,
         service: RecommendationsServiceProtocol,
         userRepo:UserRepositoryProtocol,
         workplaceServiceFactory: @escaping (() -> WorkplaceAndAssociationService),
         hostServiceFactory: @escaping (() -> HostsProviderProtocol)) {
        self.coordinator = coordinator
        self.service = service
        self.userRepo = userRepo
        self.workplaceServiceFactory = workplaceServiceFactory
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
    
    func loadData(completion: @escaping (Error?) -> Void) {
        guard let _ = userRepo.loadAccessToken()
            else {
                completion(nil)
                return
        }
        service.fetchRecommendations(userUuid: "userUuid") { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let serverList):
                self.recommendations = serverList.results
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    func numberOfSections() -> Int { 1 }
    func numberOfRowsForSection(_ section: Int) -> Int { recommendations.count }

    func recommendationTilePresenterForIndexPath(_ indexPath: IndexPath) -> RecommendationTilePresenter {
        let row = indexPath.row
        let recommendation = recommendations[row]
        if indexPath.row < tilePresenters.count {
            return tilePresenters[row]
        }
        let workplaceService = workplaceServiceFactory?()
        let hostService = hostServiceFactory?()
        let presenter = RecommendationTilePresenter(
            parent: self,
            recommendation: recommendation,
            workplaceService: workplaceService,
            hostService: hostService,
            row: row)
        tilePresenters.append(presenter)
        return presenter
    }
    
    func onTileTapped(_ tile: RecommendationTilePresenter) {
        guard let uuid = tile.recommendation.uuid else { return }
        coordinator?.onRecommendationSelected?(uuid)
    }
    
}
