import Foundation
import WorkfinderCommon
import WorkfinderCompanyDetailsUseCase
import WorkfinderViewRecommendation
import WorkfinderCoordinators

class SearchCoordinator : CoreInjectionNavigationCoordinator {
    
    let companyCoordinatorFactory: CompanyCoordinatorFactoryProtocol
    var shouldAskOperatingSystemToAllowLocation = false
    let interestsRepository: F4SSelectedInterestsRepositoryProtocol
    weak var interestsViewController: InterestsViewController?
    
    lazy var rootViewController: MapViewController = {
        let storyboard = UIStoryboard(name: "MapView", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MapViewCtrl") as! MapViewController
        vc.coordinator = self
        vc.companyFileDownloadManager = self.injected.companyDownloadFileManager
        vc.interestsRepository = self.interestsRepository
        vc.log = self.injected.log
        return vc
    }()
    
    init(parent: Coordinating,
         navigationRouter: NavigationRoutingProtocol,
         inject: CoreInjectionProtocol,
         companyCoordinatorFactory: CompanyCoordinatorFactoryProtocol,
         interestsRepository: F4SSelectedInterestsRepositoryProtocol) {
        self.companyCoordinatorFactory = companyCoordinatorFactory
        self.interestsRepository = interestsRepository
        super.init(parent: parent, navigationRouter: navigationRouter, inject: inject)
    }
    
    override func start() {
        rootViewController.coordinator = self
        rootViewController.shouldRequestAuthorization = shouldAskOperatingSystemToAllowLocation
        navigationRouter.navigationController.pushViewController(rootViewController, animated: false)
    }
    
    func processRecommendation(uuid: F4SUUID?) {
        print("process recommendation")
        guard let uuid = uuid else { return }
        rootViewController.dismiss(animated: true, completion: nil)
        if childCoordinators.count == 0 {
            startViewRecommendationCoordinator(recommendationUuid: uuid)
        } else {
            let alert = UIAlertController(title: "Show recommendation?", message: "You have an application in progress. You might want to finish this before opening the recommendation", preferredStyle: .alert)
            let recommendationAction = UIAlertAction(title: "View recommendation", style: .destructive) { (_) in
                self.navigationRouter.popToViewController(self.rootViewController, animated: true)
                self.childCoordinators.removeAll()
                self.startViewRecommendationCoordinator(recommendationUuid: uuid)
            }
            let continueAction = UIAlertAction(title: "Continue with application", style: .default) { (_) in
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
            onSuccess: { [weak self] (coordinator,workplace,hostuuid) in
                self?.childCoordinatorDidFinish(coordinator)
                self?.showDetail(workplace: workplace,
                                 hostUuid: hostuuid,
                                 originScreen: .notSpecified)
            }, onCancel: { [weak self] coordinator in
                self?.childCoordinatorDidFinish(coordinator)
        })
        addChildCoordinator(coordinator)
        coordinator.start()
    }
    
    var showingDetailForWorkplace: Workplace?

    func showDetail(workplace: Workplace?, hostUuid: F4SUUID?, originScreen: ScreenName) {
        guard let Workplace = workplace else { return }
        showingDetailForWorkplace = workplace
        rootViewController.dismiss(animated: true)
        let companyCoordinator = companyCoordinatorFactory.buildCoordinator(
            parent: self,
            navigationRouter: navigationRouter,
            workplace: Workplace,
            inject: injected, applicationFinished: { [weak self] preferredDestination in
                guard let self = self else { return }
                self.show(destination: preferredDestination)
                self.navigationRouter.popToViewController(self.rootViewController, animated: true)
        })
        addChildCoordinator(companyCoordinator)
        companyCoordinator.start()
    }
    
    func filtersButtonWasTapped() {
        guard
            let unfilteredMapModel = rootViewController.unfilteredMapModel,
            let visibleMapBounds = rootViewController.visibleMapBounds else { return }
        let interestsStoryboard = UIStoryboard(name: "InterestsView", bundle: nil)
        let interestsViewController = interestsStoryboard.instantiateViewController(withIdentifier: "interestsCtrl") as! InterestsViewController
        interestsViewController.interestsRepository = interestsRepository
        interestsViewController.allInterestsSet = interestsRepository.allInterestsSet
        interestsViewController.visibleBounds = visibleMapBounds
        interestsViewController.mapModel = unfilteredMapModel
        interestsViewController.log = injected.log
        interestsViewController.delegate = rootViewController
        let navigationController = UINavigationController(rootViewController: interestsViewController)
        self.interestsViewController = interestsViewController
        rootViewController.present(navigationController, animated: true, completion: nil)
   }
}
