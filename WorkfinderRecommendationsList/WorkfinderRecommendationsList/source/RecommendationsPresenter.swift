
import WorkfinderCommon
import WorkfinderServices

class RecommendationsPresenter {
    
    let service: RecommendationsServiceProtocol
    var recommendations = [Recommendation]()
    var tilePresenters = [Recommendation : RecommendationTilePresenter]()
    let userRepo: UserRepositoryProtocol
    var workplaceServiceFactory: (() -> WorkplaceAndAssociationService)?
    var hostServiceFactory: (() -> HostsProviderProtocol)?
    
    init(service: RecommendationsServiceProtocol,
         userRepo:UserRepositoryProtocol,
         workplaceServiceFactory: @escaping (() -> WorkplaceAndAssociationService),
         hostServiceFactory: @escaping (() -> HostsProviderProtocol)) {
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
        let recommendation = recommendations[indexPath.row]
        if let presenter = tilePresenters[recommendation] {
            return presenter
        }
        let workplaceService = workplaceServiceFactory?()
        let hostService = hostServiceFactory?()
        let presenter = RecommendationTilePresenter(
            recommendation: recommendation,
            workplaceService: workplaceService,
            hostService: hostService)
        tilePresenters[recommendation] = presenter
        return presenter
    }
    
}
