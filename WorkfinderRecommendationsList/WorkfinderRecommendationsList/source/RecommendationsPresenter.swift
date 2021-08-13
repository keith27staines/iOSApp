
import WorkfinderCommon
import WorkfinderServices

class RecommendationsPresenter {

    let pager = ServerListPager<RecommendationsListItem>()
    weak var coordinator: RecommendationsCoordinator?
    let recommendationsService: RecommendationsServiceProtocol
    let opportunitiesService: OpportunitiesServiceProtocol
    var opportunities = [ProjectJson]()
    var recommendations: [RecommendationsListItem] { pager.items }
    var recommendationTilePresenters = [RecommendationTilePresenter]()
    var opportunityTilePresenters = [OpportunityTilePresenter]()
    let userRepo: UserRepositoryProtocol
    var workplaceServiceFactory: (() -> ApplicationContextService)?
    var hostServiceFactory: (() -> HostsProviderProtocol)?
    var projectServiceFactory: (() -> ProjectServiceProtocol)?
    
    init(coordinator: RecommendationsCoordinator,
         service: RecommendationsServiceProtocol,
         userRepo:UserRepositoryProtocol,
         workplaceServiceFactory: @escaping (() -> ApplicationContextService),
         projectServiceFactory: @escaping (() -> ProjectServiceProtocol),
         opportunitiesService: OpportunitiesServiceProtocol,
         hostServiceFactory: @escaping (() -> HostsProviderProtocol)) {
        self.coordinator = coordinator
        self.recommendationsService = service
        self.userRepo = userRepo
        self.workplaceServiceFactory = workplaceServiceFactory
        self.projectServiceFactory = projectServiceFactory
        self.hostServiceFactory = hostServiceFactory
        self.opportunitiesService = opportunitiesService
    }
    
    weak var view: RecommendationsViewController?
    
    var noRecommendationsYet: Bool {
        recommendations.count == 0 ? true : false
    }
    
    func onViewDidLoad(view: RecommendationsViewController) {
        self.view = view
    }
    
    func refreshRow(_ indexPath: IndexPath) {
        view?.reloadRow([indexPath])
    }
    
    func loadFirstPage(table: UITableView, completion: @escaping (Error?) -> Void) {
        guard let _ = userRepo.loadAccessToken()
            else {
                loadOpportunities(completion: completion)
                return
        }
        recommendationsService.fetchRecommendations() { [weak self] (result) in
            guard let self = self else { return }
            self.pager.loadFirstPage(table: table, with: result) { error in
                if error == nil {
                    self.loadOpportunities(completion: completion)
                }
            }
        }
    }
    
    func loadNextPage(tableView: UITableView) {
        guard let nextPage = pager.nextPage else { return }
        recommendationsService.fetchNextPage(urlString: nextPage) { [weak self] (result) in
            guard let self = self else { return }
            self.pager.loadNextPage(table: tableView, with: result)
        }
    }
    
    func loadOpportunities(completion: @escaping (Error?) -> Void) {
        let service = opportunitiesService
        opportunities = []
        service.fetchFeaturedOpportunities { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let serverList):
                self.opportunities = serverList.results
                service.fetchRecentOpportunities { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .success(let list):
                        self.opportunities.append(contentsOf: list.results)
                        completion(nil)
                    case .failure(let error):
                        completion(error)
                    }
                }
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    func numberOfSections() -> Int {
        2
    }
    
    func numberOfRowsForSection(_ section: Int) -> Int {
        switch section {
        case 0: return recommendations.count
        case 1: return opportunities.count
        default: return 0
        }
    }

    func recommendationTilePresenterForIndexPath(_ row: Int) -> RecommendationTilePresenterProtocol {
        let recommendation = recommendations[row]
        if row < recommendationTilePresenters.count {
            return recommendationTilePresenters[row]
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
            row: row
        )
        recommendationTilePresenters.append(presenter)
        return presenter
    }
    
    func opportunityTilePresenterForIndexPath(_ row: Int) -> OpportunityTilePresenterProtocol {
        let opportunity = opportunities[row]
        if row < opportunityTilePresenters.count {
            return opportunityTilePresenters[row]
        }
        let workplaceService = workplaceServiceFactory?()
        let projectService = projectServiceFactory?()
        let hostService = hostServiceFactory?()
        let presenter = OpportunityTilePresenter(
            parent: self,
            project: opportunity,
            workplaceService: workplaceService,
            projectService: projectService,
            hostService: hostService,
            row: row
        )
        opportunityTilePresenters.append(presenter)
        return presenter
    }
    
    func onTileTapped(_ tile: ProjectPointer) {
        guard let uuid = tile.projectUuid else { return }
        coordinator?.processProjectViewRequest(uuid, appSource: .recommendationsTab
        )
    }
    
}
