import Foundation
import WorkfinderCommon
import WorkfinderCoordinators

/// RecommendationsCoordinator is responsible for:
/// 1. Instantiate views, view models and models to display a list of recommended companies
/// 2. Oversee the presentation of the view
/// 3. Manage the transition into the apply workflow should the user decide to apply to a recommendation
class RecommendationsCoordinator : CoreInjectionNavigationCoordinator {
    let companyCoordinatorFactory: CompanyCoordinatorFactoryProtocol
    
    lazy var model: RecommendedCompaniesListModelProtocol = {
        return RecommendedCompaniesListModel()
    }()
    
    lazy var viewModel: RecommendationsViewModel = {
        return RecommendationsViewModel(coordinator: self, model: model, view: rootViewController)
    }()
    
    lazy var rootViewController: RecommendationsListViewController = {
        let storyboard = UIStoryboard(name: "Recommendations", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "RecommendationsViewController") as! RecommendationsListViewController
        return controller
    }()
    
    init(parent: Coordinating?,
         navigationRouter: NavigationRoutingProtocol,
         inject: CoreInjectionProtocol,
         companyCoordinatorFactory: CompanyCoordinatorFactoryProtocol) {
        self.companyCoordinatorFactory = companyCoordinatorFactory
        super.init(parent: parent, navigationRouter: navigationRouter, inject: inject)
    }
    
    override func start() {
        rootViewController.inject(viewModel: viewModel)
        navigationRouter.navigationController.pushViewController(rootViewController, animated: false)
    }
    
    var company: Company?
    
    func showDetail(companyUuid: F4SUUID) {
        company = companyFromUuid(companyUuid)
        guard let company = company else { return }
        let companyCoordinator = companyCoordinatorFactory.makeCompanyCoordinator(parent: self, navigationRouter: navigationRouter, company: company, inject: injected)
        addChildCoordinator(companyCoordinator)
        companyCoordinator.start()
    }
    
    func companyFromUuid(_ companyUuid: F4SUUID) -> Company? {
        return DatabaseOperations.sharedInstance.companyWithUUID(companyUuid)
    }
    
}


