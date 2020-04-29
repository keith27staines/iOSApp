import Foundation
import WorkfinderCommon
import WorkfinderCoordinators

class SearchCoordinator : CoreInjectionNavigationCoordinator {
    
    let companyCoordinatorFactory: CompanyCoordinatorFactoryProtocol
    var shouldAskOperatingSystemToAllowLocation = false
    let interestsRepository: F4SInterestsRepositoryProtocol
    
    lazy var rootViewController: MapViewController = {
        let storyboard = UIStoryboard(name: "MapView", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MapViewCtrl") as! MapViewController
        vc.coordinator = self
        vc.companyFileDownloadManager = self.injected.companyDownloadFileManager
        vc.interestsRepository = self.interestsRepository
        vc.log = self.injected.log
//        vc.companyDataSource
//        vc.placesDataSource
//        vc.peopleDataSource
        return vc
    }()
    
    init(parent: Coordinating,
         navigationRouter: NavigationRoutingProtocol,
         inject: CoreInjectionProtocol,
         companyCoordinatorFactory: CompanyCoordinatorFactoryProtocol,
         interestsRepository: F4SInterestsRepositoryProtocol) {
        self.companyCoordinatorFactory = companyCoordinatorFactory
        self.interestsRepository = interestsRepository
        super.init(parent: parent, navigationRouter: navigationRouter, inject: inject)
    }
    
    override func start() {
        rootViewController.coordinator = self
        rootViewController.shouldRequestAuthorization = shouldAskOperatingSystemToAllowLocation
        navigationRouter.navigationController.pushViewController(rootViewController, animated: false)
    }
    
    var showingDetailForCompanyWorkplace: CompanyWorkplace?

    func showDetail(companyWorkplace: CompanyWorkplace?, originScreen: ScreenName) {
        guard let companyWorkplace = companyWorkplace else { return }
        showingDetailForCompanyWorkplace = companyWorkplace
        rootViewController.dismiss(animated: true)
        let companyCoordinator = companyCoordinatorFactory.makeCompanyCoordinator(
            parent: self,
            navigationRouter: navigationRouter,
            companyWorkplace: companyWorkplace,
            inject: injected, applicationFinished: { [weak self] preferredDestination in
                guard let self = self else { return }
                self.show(destination: preferredDestination)
                self.navigationRouter.popToViewController(self.rootViewController, animated: true)
        })
        companyCoordinator.originScreen = originScreen
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
        interestsViewController.visibleBounds = visibleMapBounds
        interestsViewController.mapModel = unfilteredMapModel
        interestsViewController.log = injected.log
        interestsViewController.delegate = rootViewController
        let navigationController = UINavigationController(rootViewController: interestsViewController)
        rootViewController.present(navigationController, animated: true, completion: nil)
   }
}
