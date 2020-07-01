
import WorkfinderCommon
import WorkfinderServices
import WorkfinderCoordinators

public class RecommendationsCoordinator: CoreInjectionNavigationCoordinator {
    
    public override func start() {
        let service = RecommendationsService(networkConfig: injected.networkConfig)
        let userRepo = injected.userRepository
        let presenter = RecommendationsPresenter(service: service, userRepo: userRepo)
        let vc = RecommendationsViewController(presenter: presenter)
        navigationRouter.push(viewController: vc, animated: true)
    }
}
