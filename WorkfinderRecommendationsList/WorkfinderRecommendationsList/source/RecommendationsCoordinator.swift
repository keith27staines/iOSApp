
import WorkfinderCommon
import WorkfinderServices
import WorkfinderCoordinators

public class RecommendationsCoordinator: CoreInjectionNavigationCoordinator {
    
    public override func start() {
        let service = RecommendationsService(networkConfig: injected.networkConfig)
        let presenter = RecommendationsPresenter(service: service)
        let vc = RecommendationsViewController(presenter: presenter)
        navigationRouter.push(viewController: vc, animated: true)
    }
}
