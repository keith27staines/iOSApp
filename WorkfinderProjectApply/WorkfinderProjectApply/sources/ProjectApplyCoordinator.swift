
import WorkfinderCommon
import WorkfinderCoordinators

protocol ProjectApplyCoordinatorProtocol: AnyObject {
    func onFinished()
    func onTapApply()
}

public class ProjectApplyCoordinator: CoreInjectionNavigationCoordinator {
    
    let projectUuid: F4SUUID
    weak var firstVC: UIViewController?
    
    public init(
        parent: Coordinating?,
        navigationRouter: NavigationRoutingProtocol,
        inject: CoreInjectionProtocol,
        projectUuid: F4SUUID) {
        self.projectUuid = projectUuid
        super.init(parent: parent, navigationRouter: navigationRouter, inject: inject)
    }
    
    public override func start() {
        let networkConfig = injected.networkConfig
        let presenter = ProjectPresenter(
            coordinator: self,
            projectUuid: projectUuid,
            projectService: ProjectService(networkConfig: networkConfig),
            associationDetailService: AssociationDetailService(networkConfig: networkConfig))
        let vc = ProjectViewController(coordinator: self, presenter: presenter)
        let newNav = UINavigationController(rootViewController: vc)
        navigationRouter.present(newNav, animated: true, completion: nil)
        firstVC = vc
    }
}

extension ProjectApplyCoordinator: ProjectApplyCoordinatorProtocol {
    
    func onFinished() {
        navigationRouter.dismiss(animated: true, completion: nil)
        parentCoordinator?.childCoordinatorDidFinish(self)
    }
    
    func onTapApply() {
        
    }
}
