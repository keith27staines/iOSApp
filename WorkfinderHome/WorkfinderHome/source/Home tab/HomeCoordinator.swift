import Foundation
import WorkfinderCommon
import WorkfinderCompanyDetailsUseCase
import WorkfinderViewRecommendation
import WorkfinderCoordinators
import WorkfinderServices
import WorkfinderProjectApply

extension Notification.Name {
    static let wfHomeScreenRoleTapped = Notification.Name("RoleTapped")
    static let wfHomeScreenSearchResultTapped = Notification.Name("SearchResultTapped")
    static let wfHomeScreenShowRecommendationsTapped = Notification.Name("ShowRecommendationsTapped")
    static let wfHomeScreenPopularOnWorkfinderTapped = Notification.Name("PopularOnWorkfinderTapped")
    static let wfHomeScreenErrorNotification = Notification.Name("ErrorNotification")
}

public class HomeCoordinator : CoreInjectionNavigationCoordinator {
    var projectApplyCoordinator: ProjectApplyCoordinator?
    let companyCoordinatorFactory: CompanyCoordinatorFactoryProtocol
    weak var tabNavigator: TabNavigating?
    var log: F4SAnalyticsAndDebugging { injected.log }
    
    lazy var homeViewController: HomeViewController = {
        let networkConfig = injected.networkConfig
        let vc = HomeViewController(
            coordinator: self,
            rolesService: RolesService(networkConfig: networkConfig),
            typeAheadService: TypeAheadService(networkConfig: networkConfig),
            projectTypesService: ProjectTypesService(networkConfig: networkConfig),
            employmentTypesService: EmploymentTypesService(networkConfig: networkConfig),
            skillsTypeService: SkillAcquiredTypesService(networkConfig: networkConfig),
            searchResultsController: SearchResultsController(rolesService: RolesService(networkConfig: networkConfig),
            associationsService: AssociationsService(networkConfig: networkConfig))
        )
        return vc
    }()
    
    func dispatchTypeAheadItem(_ item: TypeAheadItem) {
        guard let objectType = item.objectType, let uuid = item.uuid else { return }
        switch objectType {
        case "association", "company":
            startAssociationApply(associationUuid: uuid, source: item.applicationSource)
        case "project":
            startProjectApply(projectUuid: uuid, source: item.applicationSource)
        default:
            var title = ""
            let subtitle = "\(item.objectType ?? "")\n\(item.title ?? "")\n\(item.subtitle ?? "")"
            title = "Unexpected object type, no known routing"
            let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            navigationRouter.present(alert, animated: true, completion: nil)
        }
    }
    
    public init(parent: Coordinating,
         navigationRouter: NavigationRoutingProtocol,
         inject: CoreInjectionProtocol,
         companyCoordinatorFactory: CompanyCoordinatorFactoryProtocol,
         tabNavigator:  TabNavigating) {
        self.companyCoordinatorFactory = companyCoordinatorFactory
        self.tabNavigator = tabNavigator
        super.init(parent: parent, navigationRouter: navigationRouter, inject: inject)
        addNotificationListeners()
    }
    
    func addNotificationListeners() {
        NotificationCenter.default.addObserver(self, selector: #selector(roleTapped), name: .wfHomeScreenRoleTapped, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(navigateToRecommendationsTab), name: .wfHomeScreenShowRecommendationsTapped, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(searchResultTapped), name: .wfHomeScreenSearchResultTapped, object: nil)
    }
    
    @objc func searchResultTapped(notification: Notification) {
        guard let item = notification.object as? TypeAheadItem,
              let uuid = item.uuid else { return }
        startAssociationApply(associationUuid: uuid, source: item.applicationSource)
    }
    
    @objc func roleTapped(notification: Notification) {
        guard
            let roleData = notification.object as? RoleData,
            let id = roleData.id
        else { return }
        startProjectApply(projectUuid: id, source: roleData.applicationSource)
    }
    
    @objc func navigateToRecommendationsTab() {
        tabNavigator?.navigateToTab(tab: .recommendations)
    }
    
    public override func start() {
        homeViewController.coordinator = self
        navigationRouter.navigationController.pushViewController(homeViewController, animated: false)
    }
    
    var contextService: ApplicationContextService?
    func startAssociationApply(associationUuid: F4SUUID, source: ApplicationSource) {
        contextService = ApplicationContextService(networkConfig: injected.networkConfig)
        contextService?.fetchStartingFrom(
            associationUuid: associationUuid) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let context):
                guard
                    let companyAndPin = context.companyAndPin,
                    let associationUuid = context.associationUuid
                else { return }
                let coordinator = self.companyCoordinatorFactory.buildCoordinator(
                    parent: self,
                    navigationRouter: self.navigationRouter,
                    companyAndPin: companyAndPin,
                    recommendedAssociationUuid: associationUuid,
                    inject: self.injected,
                    applicationSource: source) { (destination) in
                }
                self.addChildCoordinator(coordinator)
                coordinator.start()
            case .failure(let error):
                print(error)
                break
            }
        }
    }
    
    func startProjectApply(projectUuid: F4SUUID, source: ApplicationSource) {
        let projectApplyCoordinator = makeProjectApplyCoordinator(project: projectUuid, source: source)
        addChildCoordinator(projectApplyCoordinator)
        projectApplyCoordinator.start()
        self.projectApplyCoordinator = projectApplyCoordinator
    }
    
    public func processRecommendation(uuid: F4SUUID?, source: ApplicationSource) {
        guard let uuid = uuid else { return }
        homeViewController.dismiss(animated: true, completion: nil)
        if childCoordinators.count == 0 {
            startViewRecommendationCoordinator(recommendationUuid: uuid, applicationSource: source)
        } else {
            let alert = UIAlertController(
                title: "View Recommendation?",
                message: "You have an application in progress. Would you like to view your recommendation or continue with your current application?",
                preferredStyle: .alert)
            let recommendationAction = UIAlertAction(title: "View recommendation", style: .destructive) { (_) in
                self.navigationRouter.popToViewController(self.homeViewController, animated: true)
                self.childCoordinators.removeAll()
                self.startViewRecommendationCoordinator(recommendationUuid: uuid, applicationSource: source)
            }
            let continueAction = UIAlertAction(title: "Continue with current application", style: .default) { (_) in
                return
            }
            alert.addAction(recommendationAction)
            alert.addAction(continueAction)
            navigationRouter.present(alert, animated: true, completion: nil)
        }
    }
    
    func startViewRecommendationCoordinator(recommendationUuid: F4SUUID, applicationSource: ApplicationSource) {
        let coordinator = ViewRecommendationCoordinator(
            recommendationUuid: recommendationUuid,
            parent: self,
            navigationRouter: navigationRouter,
            inject: injected,
            onSuccess: { [weak self] (coordinator, context) in
                self?.showDetail(
                    companyAndPin: context.companyAndPin,
                    recommendedAssociationUuid: context.associationUuid,
                    originScreen: .notSpecified)
            }, onCancel: { [weak self] coordinator in
                self?.childCoordinatorDidFinish(coordinator)
        })
        addChildCoordinator(coordinator)
        coordinator.start()
    }
    
    var showingDetailForWorkplace: CompanyAndPin?

    func showDetail(companyAndPin: CompanyAndPin?, recommendedAssociationUuid: F4SUUID?, originScreen: ScreenName) {
        guard let companyAndPin = companyAndPin else { return }
        showingDetailForWorkplace = companyAndPin
        homeViewController.dismiss(animated: true)
        let companyCoordinator = companyCoordinatorFactory.buildCoordinator(
            parent: self,
            navigationRouter: navigationRouter,
            companyAndPin: companyAndPin,
            recommendedAssociationUuid: recommendedAssociationUuid,
            inject: injected, applicationSource: .unspecified,
            applicationFinished: { [weak self] preferredDestination in
                guard let self = self else { return }
                self.show(destination: preferredDestination)
                self.navigationRouter.popToViewController(self.homeViewController, animated: true)
        })
        addChildCoordinator(companyCoordinator)
        companyCoordinator.start()
    }
}

extension HomeCoordinator: CompanyCoordinatorParentProtocol {

    public func show(destination: PreferredDestination) {
        switch destination {
        case .applications:
            tabNavigator?.navigateToTab(tab: .applications)
        case .home:
            tabNavigator?.navigateToTab(tab: .home)
        case .none:
            break
        }
    }

    public func showApplications() {
        tabNavigator?.navigateToTab(tab: .applications)
    }

    public func showHome() {
        tabNavigator?.navigateToTab(tab: .home)
    }
}

extension HomeCoordinator {
    func makeProjectApplyCoordinator(project: F4SUUID, source: ApplicationSource) -> ProjectApplyCoordinator {
        ProjectApplyCoordinator(
            parent: self,
            navigationRouter: navigationRouter,
            inject: injected,
            projectUuid: project,
            applicationSource: source,
            navigateToSearch: { [weak self] in
                self?.tabNavigator?.navigateToTab(tab: .home)
            },
            navigateToApplications: { [weak self] in
                self?.tabNavigator?.navigateToTab(tab: .applications)
            }
        )
    }
}

extension HomeCoordinator: ProjectApplyCoordinatorDelegate {
    public func onProjectApplyDidFinish() {
        
    }
}
