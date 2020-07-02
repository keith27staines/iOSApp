
import WorkfinderCommon
import WorkfinderServices
import WorkfinderCoordinators

public class RecommendationsCoordinator: CoreInjectionNavigationCoordinator {
    
    public override func start() {
        let service = RecommendationsService(networkConfig: injected.networkConfig)
        let userRepo = injected.userRepository
        let presenter = RecommendationsPresenter(
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
    
    
}