import WorkfinderCommon
import WorkfinderCoordinators
import WorkfinderUI

protocol ApplicationsCoordinatorProtocol: AnyObject {
    func applicationsDidLoad(_ applications: [Application])
    func performAction(_ action: ApplicationAction?, for application: Application)
}

public class ApplicationsCoordinator: CoreInjectionNavigationCoordinator, ApplicationsCoordinatorProtocol {
    
    var applications = [Application]()
    
    lazy var applicationsViewController: UIViewController = {
        let service = ApplicationsService()
        let presenter = ApplicationsPresenter(coordinator: self, service: service)
        let vc = ApplicationsViewController(coordinator: self, presenter: presenter)
        return vc
    }()
    
    public override func start() {
        navigationRouter.push(viewController: applicationsViewController, animated: true)
    }
    
    func applicationsDidLoad(_ applications: [Application]) {
        self.applications = applications
    }
    
    func performAction(_ action: ApplicationAction?, for application: Application) {
        guard let action = action else { return }
        switch action {
        case .viewApplication: showApplicationDetailViewer(for: application)
        case .viewOffer: break
        case .acceptOffer: break
        case .declineOffer: break
        }
    }
    
    func showApplicationDetailViewer(for application: Application) {
        let service = ApplicationDetailService()
        let presenter = ApplicationDetailPresenter(
            coordinator: self,
            service: service,
            application: application)
        let vc = ApplicationDetailViewController(
            coordinator: self,
            presenter: presenter)
        navigationRouter.push(viewController: vc, animated: true)
    }
}



