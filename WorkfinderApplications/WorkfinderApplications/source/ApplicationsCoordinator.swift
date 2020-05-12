import WorkfinderCommon
import WorkfinderCoordinators
import WorkfinderUI

public protocol ApplicationsCoordinatorProtocol {
    
}

public class ApplicationsCoordinator: CoreInjectionNavigationCoordinator, ApplicationsCoordinatorProtocol {
    
    
    
    lazy var applicationsViewController: UIViewController = {
        let vc = ApplicationsViewController()
        return vc
    }()
    
    public override func start() {
        navigationRouter.push(viewController: applicationsViewController, animated: true)
    }
}
