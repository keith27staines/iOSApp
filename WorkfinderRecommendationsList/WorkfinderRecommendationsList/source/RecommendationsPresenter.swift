
import WorkfinderCommon
import WorkfinderServices

class RecommendationsPresenter {

    weak var coordinator: RecommendationsCoordinator?
    let recommendationsService: RecommendationsServiceProtocol
    let opportunitiesService: OpportunitiesServiceProtocol
    var opportunities = [ProjectJson]()
    var recommendations = [RecommendationsListItem]()
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
        view?.reloadRow(indexPath)
    }
    
    private var numberLeftToFill: Int {
        6 - recommendations.count - opportunities.count
    }
    
    private func clearData(table: UITableView) {
        recommendations = []
        opportunities = []
        recommendationTilePresenters = []
        opportunityTilePresenters = []
        table.reloadData()
    }
    
    func loadFirstPage(table: UITableView, completion: @escaping (Error?) -> Void) {
        clearData(table: table)
        guard let _ = userRepo.loadAccessToken()
        else {
            loadOpportunities(completion: completion)
            return
        }
        recommendationsService.fetchRecommendations() { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            
            case .success(let serverList):
                self.recommendations = [RecommendationsListItem](serverList.results.prefix(6))
                if self.recommendations.count < 6 {
                    self.loadOpportunities(completion: completion)
                } else {
                    completion(nil)
                }
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    func loadOpportunities(completion: @escaping (Error?) -> Void) {
        let service = opportunitiesService
        opportunities = []
        service.fetchRecentOpportunities { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let serverList):
                let projects = [ProjectJson](serverList.results.filter({
                    $0.hasApplied ?? false == false
                }).prefix(self.numberLeftToFill))
                self.opportunities.append(contentsOf: projects)
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    func numberOfSections() -> Int { 2 }
    
    func numberOfRowsForSection(_ section: Int) -> Int {
        switch section {
        case 0: return recommendations.count
        case 1: return opportunities.count
        default: return 0
        }
    }

    func recommendationTilePresenterForIndexPath(_ row: Int) -> OpportunityTilePresenterProtocol {
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
        let presenter = OpportunityTilePresenter(
            parent: self,
            project: opportunity,
            row: row
        )
        opportunityTilePresenters.append(presenter)
        return presenter
    }
    
    func onTileTapped(_ tile: ProjectPointer) {
        guard let uuid = tile.projectUuid else { return }
        coordinator?.processProjectViewRequest(uuid, appSource: .recommendationsTab)
    }
    
    lazy var projectService: ProjectServiceProtocol? = {
        projectServiceFactory?()
    }()
    
    func onApplyButtonTapped(_ projectInfo: ProjectInfoPresenter) {
        var projectInfo = projectInfo
        view?.messageHandler?.showLoadingOverlay()
        projectService?.fetchHost(uuid: projectInfo.hostUuid, completion: { [weak self] result in
            guard let self = self else { return }
            self.view?.messageHandler?.hideLoadingOverlay()
            switch result {
            case .success(let hostJson):
                projectInfo.hostUuid = hostJson.uuid ?? ""
                let name = hostJson.fullName ?? ""
                projectInfo.hostName = name.isEmpty ? "Sir/Madam" : name
                self.coordinator?.processQuickApplyRequest(projectInfo, appSource: .recommendationsTab)
            case .failure(let error):
                self.view?.messageHandler?.displayOptionalErrorIfNotNil(error, retryHandler: {
                    self.onApplyButtonTapped(projectInfo)
                })
            }
        })
    }

}
