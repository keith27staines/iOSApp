
import WorkfinderCommon
import WorkfinderServices
import WorkfinderCoordinators

public class RecommendationsCoordinator: CoreInjectionNavigationCoordinator {
    
    public override func start() {
        let service = RecommendationsService(networkConfig: injected.networkConfig)
        let presenter = RecommendationsPresenter(service: service)
        let vc = RecommendationsViewController(presenter: presenter)
        navigationRouter.present(vc, animated: true, completion: nil)
    }
}
