
import WorkfinderCommon
import UIKit
import WorkfinderServices

class RecommendationsPresenter {

    weak var coordinator: RecommendationsCoordinator?
    let recommendationsService: RecommendationsServiceProtocol
    let opportunitiesService: OpportunitiesServiceProtocol
    
    var opportunities = [ProjectJson]()
    var recommendations = [RecommendationsListItem]()
    
    let userRepo: UserRepositoryProtocol
    var workplaceServiceFactory: (() -> ApplicationContextService)?
    var hostServiceFactory: (() -> HostsProviderProtocol)?
    var projectServiceFactory: (() -> ProjectServiceProtocol)?
    
    var table: UITableView?
    
    var datasource: Datasource?
    var snapshot: Snapshot?
    
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
    
    enum Section: CaseIterable {
        case recommendations
        case opportunities
    }
    
    typealias Datasource = UITableViewDiffableDataSource<Section, OpportunityTileData>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, OpportunityTileData>
    
    var noRecommendationsYet: Bool {
        recommendations.count == 0 ? true : false
    }
    
    func onViewDidLoad(view: RecommendationsViewController, table: UITableView) {
        self.view = view
        self.table = table
        datasource = makeDatasource(for: table)
    }
    
    private func makeDatasource(for table: UITableView) -> Datasource {
        let datasource = Datasource(tableView: table) { tableView, indexPath, itemIdentifier in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: OpportunityTileCellView.reuseIdentifier) as? OpportunityTileCellView
            else { return UITableViewCell() }
            cell.data = itemIdentifier
            return cell
        }
        return datasource
    }
    let maximumNumberOfTiles = 30
    private var numberLeftToFill: Int {
        maximumNumberOfTiles - recommendations.count - opportunities.count
    }
    
    func applySnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections(Section.allCases)
        let recommendationTilePresenters = recommendations.map { recommendation in
            OpportunityTileData(parent: self, recommendation: recommendation)
        }
        let opportunityTilePresenters = opportunities.map { project in
            OpportunityTileData(parent: self, project: project)
        }
        snapshot.appendItems(recommendationTilePresenters, toSection: Section.recommendations)
        snapshot.appendItems(opportunityTilePresenters, toSection: Section.opportunities)
        let isAnimated = self.snapshot != nil
        self.snapshot = snapshot
        datasource?.apply(snapshot, animatingDifferences: isAnimated, completion: nil)
    }
    
    func loadData(completion: @escaping (Error?) -> Void) {
        opportunities = []
        recommendations = []
        guard let _ = userRepo.loadAccessToken()
        else {
            loadOpportunities(completion: completion)
            return
        }
        recommendationsService.fetchRecommendations() { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let serverList):
                self.recommendations = [RecommendationsListItem](serverList.results.prefix(self.numberLeftToFill))
                if self.recommendations.count < self.numberLeftToFill {
                    self.loadOpportunities(completion: completion)
                } else {
                    completion(nil)
                }
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    private func loadOpportunities(completion: @escaping (Error?) -> Void) {
        let service = opportunitiesService
        opportunities = []
        service.fetchRecentOpportunities { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let serverList):
                let projects = [ProjectJson](serverList.results.prefix(self.numberLeftToFill))
                self.opportunities.append(contentsOf: projects)
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
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
