
import WorkfinderCommon
import WorkfinderServices
import WorkfinderCoordinators
import WorkfinderProjectApply

public class RecommendationsCoordinator: CoreInjectionNavigationCoordinator {
    
    public override func start() {
        let service = RecommendationsService(networkConfig: injected.networkConfig)
        let userRepo = injected.userRepository
        let presenter = RecommendationsPresenter(
            coordinator: self,
            service: service,
            userRepo: userRepo,
            workplaceServiceFactory: workplaceServiceFactory,
            projectServiceFactory: projectServiceFactory,
            hostServiceFactory: hostServiceFactory)
        let vc = RecommendationsViewController(presenter: presenter)
        navigationRouter.push(viewController: vc, animated: true)
    }
    
    func workplaceServiceFactory() -> ApplicationContextService {
        ApplicationContextService(networkConfig: injected.networkConfig)
    }
    
    func projectServiceFactory() -> ProjectServiceProtocol {
        ProjectService(networkConfig: injected.networkConfig)
    }
    
    func hostServiceFactory() -> HostsProviderProtocol {
        HostsProvider(networkConfig: injected.networkConfig)
    }
        
    weak var projectApplyCoordinator: ProjectApplyCoordinator?
    
    public func processProjectViewRequest(_ projectUuid: F4SUUID?, applicationSource: AppSource) {
        guard let projectUuid = projectUuid else { return }
        let projectApplyCoordinator = ProjectApplyCoordinator(
            parent: self,
            navigationRouter: navigationRouter,
            inject: injected,
            projectUuid: projectUuid,
            applicationSource: applicationSource,
            navigateToSearch: navigateToSearch,
            navigateToApplications: navigateToApplications)
        addChildCoordinator(projectApplyCoordinator)
        self.projectApplyCoordinator = projectApplyCoordinator
        projectApplyCoordinator.start()
    }
    
    var navigateToSearch: (() -> Void)?
    var navigateToApplications: (() -> Void)?
    
    public var onRecommendationSelected: ((F4SUUID) -> Void)?
    
    public init(
        parent: Coordinating?,
        navigationRouter: NavigationRoutingProtocol,
        inject: CoreInjectionProtocol,
        navigateToSearch: (() -> Void)?,
        navigateToApplications: (() -> Void)?) {
        self.navigateToSearch = navigateToSearch
        self.navigateToApplications = navigateToApplications
        super.init(parent: parent, navigationRouter: navigationRouter, inject: inject)
    }
    
}

extension RecommendationsCoordinator: ProjectApplyCoordinatorDelegate {
    public func onProjectApplyDidFinish() {
        self.projectApplyCoordinator = nil
    }
}

