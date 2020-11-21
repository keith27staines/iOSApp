import Foundation
import WorkfinderCommon
import WorkfinderCompanyDetailsUseCase
import WorkfinderViewRecommendation
import WorkfinderCoordinators

class SearchCoordinator : CoreInjectionNavigationCoordinator {
    
    let companyCoordinatorFactory: CompanyCoordinatorFactoryProtocol
    var shouldAskOperatingSystemToAllowLocation = false
    
    lazy var rootViewController: MapViewController = {
        let vc = MapViewController()
        vc.coordinator = self
        return vc
    }()
    
    init(parent: Coordinating,
         navigationRouter: NavigationRoutingProtocol,
         inject: CoreInjectionProtocol,
         companyCoordinatorFactory: CompanyCoordinatorFactoryProtocol) {
        self.companyCoordinatorFactory = companyCoordinatorFactory
        super.init(parent: parent, navigationRouter: navigationRouter, inject: inject)
    }
    
    override func start() {
        rootViewController.coordinator = self
        navigationRouter.navigationController.pushViewController(rootViewController, animated: false)
    }
    
    func processRecommendation(uuid: F4SUUID?) {
        guard let uuid = uuid else { return }
        rootViewController.dismiss(animated: true, completion: nil)
        if childCoordinators.count == 0 {
            startViewRecommendationCoordinator(recommendationUuid: uuid)
        } else {
            let alert = UIAlertController(title: "View Recommendation?", message: "You have an application in progress. Would you like to view your recommendation or continue with your current application?", preferredStyle: .alert)
            let recommendationAction = UIAlertAction(title: "View recommendation", style: .destructive) { (_) in
                self.navigationRouter.popToViewController(self.rootViewController, animated: true)
                self.childCoordinators.removeAll()
                self.startViewRecommendationCoordinator(recommendationUuid: uuid)
            }
            let continueAction = UIAlertAction(title: "Continue with current application", style: .default) { (_) in
                return
            }
            alert.addAction(recommendationAction)
            alert.addAction(continueAction)
            navigationRouter.present(alert, animated: true, completion: nil)
        }
    }
    
    func startViewRecommendationCoordinator(recommendationUuid: F4SUUID) {
        let coordinator = ViewRecommendationCoordinator(
            recommendationUuid: recommendationUuid,
            parent: self,
            navigationRouter: navigationRouter,
            inject: injected,
            onSuccess: { [weak self] (coordinator,workplace,recommendedAssociationUuid) in
                self?.showDetail(workplace: workplace,
                                 recommendedAssociationUuid: recommendedAssociationUuid,
                                 originScreen: .notSpecified)
            }, onCancel: { [weak self] coordinator in
                self?.childCoordinatorDidFinish(coordinator)
        })
        addChildCoordinator(coordinator)
        coordinator.start()
    }
    
    var showingDetailForWorkplace: Workplace?

    func showDetail(workplace: Workplace?, recommendedAssociationUuid: F4SUUID?, originScreen: ScreenName) {
        guard let Workplace = workplace else { return }
        showingDetailForWorkplace = workplace
        rootViewController.dismiss(animated: true)
        let companyCoordinator = companyCoordinatorFactory.buildCoordinator(
            parent: self,
            navigationRouter: navigationRouter,
            workplace: Workplace,
            recommendedAssociationUuid: recommendedAssociationUuid,
            inject: injected, applicationFinished: { [weak self] preferredDestination in
                guard let self = self else { return }
                self.show(destination: preferredDestination)
                self.navigationRouter.popToViewController(self.rootViewController, animated: true)
        })
        addChildCoordinator(companyCoordinator)
        companyCoordinator.start()
    }
}
