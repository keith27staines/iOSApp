
import WorkfinderCommon
import WorkfinderServices
import WorkfinderCoordinators
import WorkfinderProjectApply

public class RecommendationsCoordinator: CoreInjectionNavigationCoordinator {
    
    public override func start() {
        let service = RecommendationsService(networkConfig: injected.networkConfig)
        let userRepo = injected.userRepository
        let presenter = RecommendationsPresenter(
            coordinator: self,
            service: service,
            userRepo: userRepo,
            workplaceServiceFactory: workplaceServiceFactory,
            hostServiceFactory: hostServiceFactory)
        let vc = RecommendationsViewController(presenter: presenter)
        navigationRouter.push(viewController: vc, animated: true)
    }
    
    func workplaceServiceFactory() -> WorkplaceAndAssociationService {
        WorkplaceAndAssociationService(networkConfig: injected.networkConfig)
    }
    
    func hostServiceFactory() -> HostsProviderProtocol {
        HostsProvider(networkConfig: injected.networkConfig)
    }
    
    weak var projectApplyCoordinator: ProjectApplyCoordinator?
    
    public func processProjectViewRequest(_ projectUuid: F4SUUID) {
        guard projectApplyCoordinator == nil else {
            return
        }
        let projectApplyCoordinator = ProjectApplyCoordinator(
            parent: self,
            navigationRouter: navigationRouter,
            inject: injected,
            projectUuid: projectUuid)
        addChildCoordinator(projectApplyCoordinator)
        self.projectApplyCoordinator = projectApplyCoordinator
        projectApplyCoordinator.start()
    }
    
    public var onRecommendationSelected: ((F4SUUID) -> Void)?
    
    
}
