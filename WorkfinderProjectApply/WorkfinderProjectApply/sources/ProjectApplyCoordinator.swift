
import WorkfinderCommon
import WorkfinderCoordinators

class ProjectApplyCoordinator: CoreInjectionNavigationCoordinator {
    
    let projectUuid: F4SUUID
    
    init(
        parent: Coordinating?,
        navigationRouter: NavigationRoutingProtocol,
        inject: CoreInjectionProtocol,
        projectUuid: F4SUUID) {
        self.projectUuid = projectUuid
        super.init(parent: parent, navigationRouter: navigationRouter, inject: inject)
    }
    
    weak var firstVC: UIViewController?
    
    override func start() {
        let presenter = ProjectPresenter(
            projectUuid: projectUuid,
            projectService: ProjectService(networkConfig: injected.networkConfig))
        let vc = ProjectViewController(presenter: presenter)
        navigationRouter.push(viewController: vc, animated: true)
        firstVC = vc
    }
}
