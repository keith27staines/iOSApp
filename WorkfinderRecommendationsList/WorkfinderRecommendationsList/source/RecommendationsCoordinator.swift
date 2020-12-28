
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
    
    public func processProjectViewRequest(_ projectUuid: F4SUUID?, appSource: AppSource) {
        guard let projectUuid = projectUuid else { return }
        let projectApplyCoordinator = ProjectApplyCoordinator(
            parent: self,
            navigationRouter: navigationRouter,
            inject: injected,
            projectUuid: projectUuid,
            appSource: appSource,
            switchToTab: switchToTab
        )
        addChildCoordinator(projectApplyCoordinator)
        self.projectApplyCoordinator = projectApplyCoordinator
        projectApplyCoordinator.start()
    }
    
    var switchToTab: ((TabIndex) -> Void)?
    
    public init(
        parent: Coordinating?,
        navigationRouter: NavigationRoutingProtocol,
        inject: CoreInjectionProtocol,
        switchToTab: ((TabIndex) -> Void)?
    ) {
        self.switchToTab = switchToTab
        super.init(parent: parent, navigationRouter: navigationRouter, inject: inject)
    }
}

extension RecommendationsCoordinator: ProjectApplyCoordinatorDelegate {
    public func onProjectApplyDidFinish() {
        self.projectApplyCoordinator = nil
    }
}

