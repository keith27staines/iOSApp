import Foundation
import WorkfinderCommon
import WorkfinderCoordinators


let __bundle = Bundle(identifier: "com.f4s.WorkfinderRecommendations")

/// RecommendationsCoordinator is responsible for:
/// 1. Instantiate views, view models and models to display a list of recommended companies
/// 2. Oversee the presentation of the view
/// 3. Manage the transition into the apply workflow should the user decide to apply to a recommendation
public class RecommendationsCoordinator : CoreInjectionNavigationCoordinator {
    let companyCoordinatorFactory: CompanyCoordinatorFactoryProtocol
    let companyRepository: F4SCompanyRepositoryProtocol
    let recommendationsService: F4SRecommendationServiceProtocol
    weak var tabBarCoordinator: TabBarCoordinatorProtocol?
    
    lazy var model: RecommendedCompaniesListModelProtocol = {
        return RecommendedCompaniesListModel(recommendationsService: recommendationsService)
    }()
    
    lazy var viewModel: RecommendationsViewModel = {
        return RecommendationsViewModel(coordinator: self,
                                        model: model,
                                        view: rootViewController,
                                        companyRepository: companyRepository)
    }()
    
    lazy var rootViewController: RecommendationsListViewController = {
        let storyboard = UIStoryboard(name: "Recommendations", bundle: __bundle)
        let controller = storyboard.instantiateViewController(withIdentifier: "RecommendationsViewController") as! RecommendationsListViewController
        controller.coordinator = self
        controller.log = self.injected.log
        return controller
    }()
    
    public func updateBadges() {
        viewModel.reload()
    }
    
    public init(parent: TabBarCoordinatorProtocol,
         navigationRouter: NavigationRoutingProtocol,
         inject: CoreInjectionProtocol,
         companyCoordinatorFactory: CompanyCoordinatorFactoryProtocol,
         companyRepository: F4SCompanyRepositoryProtocol,
         recommendationsService: F4SRecommendationServiceProtocol) {
        self.tabBarCoordinator = parent
        self.companyCoordinatorFactory = companyCoordinatorFactory
        self.companyRepository = companyRepository
        self.recommendationsService = recommendationsService
        super.init(parent: parent, navigationRouter: navigationRouter, inject: inject)
    }
    
    public override func start() {
        rootViewController.inject(viewModel: viewModel)
        navigationRouter.navigationController.pushViewController(rootViewController, animated: false)
    }
    
    var company: Company?
    
    func showDetail(companyUuid: F4SUUID) {
        injected.log.track(event: .recommendationsShowCompanyTap, properties: nil)
        company = companyFromUuid(companyUuid)
        guard let company = company else { return }
        let companyCoordinator = companyCoordinatorFactory.makeCompanyCoordinator(parent: self, navigationRouter: navigationRouter, company: company, inject: injected)
        companyCoordinator.originScreen = rootViewController.screenName
        addChildCoordinator(companyCoordinator)
        companyCoordinator.start()
    }
    
    func companyFromUuid(_ companyUuid: F4SUUID) -> Company? {
        companyRepository.load(companyUuid: companyUuid)
    }
}

extension RecommendationsCoordinator: CompanyCoordinatorParentProtocol {
    public func showMessages() {
       tabBarCoordinator?.showMessages()
    }
    
    public func showSearch() {
        tabBarCoordinator?.showSearch()
    }
}

extension RecommendationsCoordinator {
    func toggleMenu() {
        tabBarCoordinator?.toggleMenu(completion: nil)
    }
    
}
