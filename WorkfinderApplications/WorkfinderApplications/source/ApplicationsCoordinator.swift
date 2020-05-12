import WorkfinderCommon
import WorkfinderCoordinators
import WorkfinderUI

protocol ApplicationsCoordinatorProtocol: AnyObject {
    func presentApplicationDetail(for application: ApplicationsPresenter.ApplicationPresenter)
}

class ApplicationsCoordinator: CoreInjectionNavigationCoordinator, ApplicationsCoordinatorProtocol {
    
    
    lazy var applicationsViewController: UIViewController = {
        let presenter = ApplicationsPresenter()
        let vc = ApplicationsViewController(coordinator: self, presenter: presenter)
        return vc
    }()
    
    override func start() {
        navigationRouter.push(viewController: applicationsViewController, animated: true)
    }
    
    func presentApplicationDetail(for application: ApplicationsPresenter.ApplicationPresenter) {
        <#code#>
    }
}
