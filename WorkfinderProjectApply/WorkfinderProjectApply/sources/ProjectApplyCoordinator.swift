
import WorkfinderCommon
import WorkfinderCoordinators

public class ProjectApplyCoordinator: CoreInjectionNavigationCoordinator {
    
    let projectUuid: F4SUUID
    
    public init(
        parent: Coordinating?,
        navigationRouter: NavigationRoutingProtocol,
        inject: CoreInjectionProtocol,
        projectUuid: F4SUUID) {
        self.projectUuid = projectUuid
        super.init(parent: parent, navigationRouter: navigationRouter, inject: inject)
    }
    
    weak var firstVC: UIViewController?
    
    public override func start() {
        let presenter = ProjectPresenter(
            projectUuid: projectUuid,
            projectService: ProjectService(networkConfig: injected.networkConfig))
        let vc = ProjectViewController(presenter: presenter)
        let newNav = UINavigationController(rootViewController: vc)
        navigationRouter.present(newNav, animated: true, completion: nil)
        firstVC = vc
    }
}
