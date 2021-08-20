
import WorkfinderCommon
import WorkfinderServices
import WorkfinderCoordinators
import WorkfinderProjectApply
import WorkfinderUI

public class RecommendationsCoordinator: CoreInjectionNavigationCoordinator {
    
    weak var rootViewController: (UIViewController & UserMessageHandlingProtocol)?
    //weak var projectApplyCoordinator: ProjectApplyCoordinator?
    
    public override func start() {
        let recommendationsService = RecommendationsService(networkConfig: injected.networkConfig)
        let opportunitiesService = OpportuntiesService(networkConfig: injected.networkConfig)
        let userRepo = injected.userRepository
        let presenter = RecommendationsPresenter(
            coordinator: self,
            service: recommendationsService,
            userRepo: userRepo,
            workplaceServiceFactory: workplaceServiceFactory,
            projectServiceFactory: projectServiceFactory,
            opportunitiesService: opportunitiesService,
            hostServiceFactory: hostServiceFactory)
        let rootViewController = RecommendationsViewController(presenter: presenter)
        navigationRouter.push(viewController: rootViewController, animated: true)
        self.rootViewController = rootViewController
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
        // self.projectApplyCoordinator = projectApplyCoordinator
        projectApplyCoordinator.start()
    }
    
    public func processQuickApplyRequest(_ projectInfo: ProjectInfoPresenter, appSource: AppSource) {
        guard let rootViewController = rootViewController else { return }
        let projectApplyCoordinator = ProjectQuickApplyCoordinator(
            parent: self,
            navigationRouter: navigationRouter,
            userMessageHandlingVC: rootViewController,
            inject: injected,
            projectInfoPresenter: projectInfo,
            appSource: appSource,
            switchToTab: switchToTab
        )
        addChildCoordinator(projectApplyCoordinator)
        // self.projectApplyCoordinator = projectApplyCoordinator
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
        // self.projectApplyCoordinator = nil
    }
}

