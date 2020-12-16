import WorkfinderCommon
import WorkfinderServices
import WorkfinderCoordinators
import WorkfinderUI

public class ViewRecommendationCoordinator: CoreInjectionNavigationCoordinator {
    
    let recommendationUuid: F4SUUID
    
    var onSuccess: (ViewRecommendationCoordinator, ApplicationContext) -> Void
    var onCancel: (ViewRecommendationCoordinator) -> Void
    
    public init(recommendationUuid: F4SUUID,
                parent: Coordinating?,
                navigationRouter: NavigationRoutingProtocol,
                inject: CoreInjectionProtocol,
                onSuccess: @escaping (ViewRecommendationCoordinator, ApplicationContext) -> Void,
                onCancel: @escaping (ViewRecommendationCoordinator) -> Void) {
        self.recommendationUuid = recommendationUuid
        self.onSuccess = onSuccess
        self.onCancel = onCancel
        super.init(parent: parent, navigationRouter: navigationRouter, inject: inject)
    }
    var vc: UIViewController?
    public override func start() {
        let service = ApplicationContextService(networkConfig: injected.networkConfig)
        let presenter = LoadingViewPresenter(
            recommendationUuid: recommendationUuid,
            service: service,
            coordinator: self)
        let vc = LoadingViewController(presenter: presenter)
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        navigationRouter.present(vc, animated: true, completion: nil)
        self.vc = vc
    }
    
    func presenterDidCancel() {
        parentCoordinator?.childCoordinatorDidFinish(self)
        vc?.dismiss(animated: true, completion: nil)
        onCancel(self)
    }
    
    func onApplicationContextObtainedFromRecommendation(_ context: ApplicationContext) {
        vc?.dismiss(animated: true, completion: nil)
        parentCoordinator?.childCoordinatorDidFinish(self)
        onSuccess(self, context)
    }
}


