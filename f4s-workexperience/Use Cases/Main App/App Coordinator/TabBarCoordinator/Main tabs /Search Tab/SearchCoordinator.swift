import Foundation
import WorkfinderCommon
import WorkfinderCoordinators

class SearchCoordinator : CoreInjectionNavigationCoordinator {
    
    var shouldAskOperatingSystemToAllowLocation = false
    
    lazy var rootViewController: MapViewController = {
        let storyboard = UIStoryboard(name: "MapView", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MapViewCtrl") as! MapViewController
        vc.coordinator = self
        return vc
    }()
    
    override func start() {
        rootViewController.coordinator = self
        rootViewController.shouldRequestAuthorization = shouldAskOperatingSystemToAllowLocation
        navigationRouter.navigationController.pushViewController(rootViewController, animated: false)
    }
    
    var showingDetailForCompany: Company?

    func showDetail(company: Company?) {
        guard let company = company else { return }
        showingDetailForCompany = company
        rootViewController.dismiss(animated: true)
        let companyCoordinator = CompanyCoordinator(parent: self, navigationRouter: navigationRouter, company: company, inject: injected)
        addChildCoordinator(companyCoordinator)
        companyCoordinator.start()
    }
    
    func filtersButtonWasTapped() {
        guard
            let unfilteredMapModel = rootViewController.unfilteredMapModel,
            let visibleMapBounds = rootViewController.visibleMapBounds else { return }
        let interestsStoryboard = UIStoryboard(name: "InterestsView", bundle: nil)
        let interestsViewController = interestsStoryboard.instantiateViewController(withIdentifier: "interestsCtrl") as! InterestsViewController
        interestsViewController.visibleBounds = visibleMapBounds
        interestsViewController.mapModel = unfilteredMapModel
        interestsViewController.delegate = rootViewController
        let navigationController = UINavigationController(rootViewController: interestsViewController)
        rootViewController.present(navigationController, animated: true, completion: nil)
   }
}
