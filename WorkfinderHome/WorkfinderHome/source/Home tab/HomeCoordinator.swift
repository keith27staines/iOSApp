import Foundation
import WorkfinderCommon
import WorkfinderCompanyDetailsUseCase
import WorkfinderViewRecommendation
import WorkfinderCoordinators
import WorkfinderServices
import WorkfinderProjectApply

extension Notification.Name {
    static let wfHomeScreenRoleTapped = Notification.Name("RoleTapped")
    static let wfHomeScreenShowRecommendationsTapped = Notification.Name("ShowRecommendationsTapped")
    static let wfHomeScreenPopularOnWorkfinderTapped = Notification.Name("PopularOnWorkfinderTapped")
}

public class HomeCoordinator : CoreInjectionNavigationCoordinator {
    var projectApplyCoordinator: ProjectApplyCoordinator?
    let companyCoordinatorFactory: CompanyCoordinatorFactoryProtocol
    weak var tabNavigator: TabNavigating?
    public var shouldAskOperatingSystemToAllowLocation = false
    
    lazy var rootViewController: HomeViewController = {
        let networkConfig = injected.networkConfig
        let vc = HomeViewController(
            coordinator: self,
            rolesService: RolesService(networkConfig: networkConfig),
            typeAheadService: TypeAheadService(networkConfig: networkConfig),
            projectTypesService: ProjectTypesService(networkConfig: networkConfig),
            employmentTypesService: EmploymentTypesService(networkConfig: networkConfig),
            skillsTypeService: SkillAcquiredTypesService(networkConfig: networkConfig),
            searchResultsController: SearchResultsController(rolesService: RolesService(networkConfig: networkConfig))
        )
        vc.coordinator = self
        return vc
    }()
    
    func dispatchTypeAheadItem(_ item: TypeAheadItem) {
        guard let objectType = item.objectType, let uuid = item.uuid else { return }
        let source = ApplicationSource.homeTabTypeAhead
        switch objectType {
        case "association":
            startAssociationApply(associationUuid: uuid, source: source)
            return
        case "project":
            startProjectApply(projectUuid: uuid, source: source)
            return
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
    }
    
    @objc func roleTapped(notification: Notification) {
        guard
            let roleData = notification.object as? RoleData,
            let id = roleData.id
        else { return }
        startProjectApply(projectUuid: id, source: .homeTab)
    }
    
    @objc func navigateToRecommendationsTab() {
        tabNavigator?.navigateToTab(tab: .recommendations)
    }
    
    public override func start() {
        rootViewController.coordinator = self
        navigationRouter.navigationController.pushViewController(rootViewController, animated: false)
    }
    
    func startAssociationApply(associationUuid: F4SUUID, source: ApplicationSource) {
        
        let passiveApplyContextService = WorkplaceAndAssociationService(networkConfig: injected.networkConfig)

//        let companyAndPin = CompanyAndPin(companyJson: <#T##CompanyJson#>, locationPin: <#T##LocationPin#>)
//        let coordinator = companyCoordinatorFactory.buildCoordinator(
//            parent: self,
//            navigationRouter: navigationRouter,
//            companyAndPin: <#T##CompanyAndPin#>,
//            recommendedAssociationUuid: <#T##F4SUUID?#>,
//            inject: <#T##CoreInjectionProtocol#>,
//            applicationFinished: <#T##((PreferredDestination) -> Void)##((PreferredDestination) -> Void)##(PreferredDestination) -> Void#>)
    }
    
    func startProjectApply(projectUuid: F4SUUID, source: ApplicationSource) {
        let projectApplyCoordinator = makeProjectApplyCoordinator(project: projectUuid, source: source)
        addChildCoordinator(projectApplyCoordinator)
        projectApplyCoordinator.start()
        self.projectApplyCoordinator = projectApplyCoordinator
    }
    
    public func processRecommendation(uuid: F4SUUID?) {
        guard let uuid = uuid else { return }
        rootViewController.dismiss(animated: true, completion: nil)
        if childCoordinators.count == 0 {
            startViewRecommendationCoordinator(recommendationUuid: uuid)
        } else {
            let alert = UIAlertController(
                title: "View Recommendation?",
                message: "You have an application in progress. Would you like to view your recommendation or continue with your current application?",
                preferredStyle: .alert)
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
                self?.showDetail(companyAndPin: workplace,
                                 recommendedAssociationUuid: recommendedAssociationUuid,
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
        rootViewController.dismiss(animated: true)
        let companyCoordinator = companyCoordinatorFactory.buildCoordinator(
            parent: self,
            navigationRouter: navigationRouter,
            companyAndPin: companyAndPin,
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
