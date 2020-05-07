import WorkfinderCommon
import WorkfinderCoordinators

public protocol ApplicationsCoordinatorProtocol {
    
}

public class ApplicationsCoordinator: CoreInjectionNavigationCoordinator, ApplicationsCoordinatorProtocol {
    
    lazy var rootViewController: UIViewController = {
        let vc = UIViewController()
        vc.view.backgroundColor = UIColor.red
        return vc
    }()
    
    public override func start() {
        navigationRouter.push(viewController: rootViewController, animated: true)
    }
}
