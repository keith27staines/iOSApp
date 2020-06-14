import WorkfinderCommon
import WorkfinderServices
import WorkfinderCoordinators
import WorkfinderUI
import WorkfinderCompanyDetailsUseCase

public class ViewRecommendationCoordinator: CoreInjectionNavigationCoordinator {
    
    let recommendationUuid: F4SUUID
    
    /// tuple containing this coordinator, a Workplace and a host uuid
    var onSuccess: (ViewRecommendationCoordinator, Workplace, F4SUUID) -> Void
    var onCancel: (ViewRecommendationCoordinator) -> Void
    
    public init(recommendationUuid: F4SUUID,
                parent: Coordinating?,
                navigationRouter: NavigationRoutingProtocol,
                inject: CoreInjectionProtocol,
                onSuccess: @escaping (ViewRecommendationCoordinator, Workplace, F4SUUID) -> Void,
                onCancel: @escaping (ViewRecommendationCoordinator) -> Void) {
        self.recommendationUuid = recommendationUuid
        self.onSuccess = onSuccess
        self.onCancel = onCancel
        super.init(parent: parent, navigationRouter: navigationRouter, inject: inject)
    }
    
    public override func start() {
        let service = WorkplaceAndHostService(networkConfig: injected.networkConfig)
        let presenter = LoadingViewPresenter(
            recommendationUuid: recommendationUuid,
            service: service,
            coordinator: self)
        let vc = LoadingViewController(presenter: presenter)
        navigationRouter.push(viewController: vc, animated: true)
    }
    
    func onWorkplaceAndHostObtainedFromRecommendation(_ value: WorkplaceAndHostUuid) {
        onSuccess(self, value.0, value.1)
//        navigationRouter.pop(animated: true)
        parentCoordinator?.childCoordinatorDidFinish(self)
    }
    
}


