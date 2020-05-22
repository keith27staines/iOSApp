import WorkfinderCommon
import WorkfinderCoordinators
import WorkfinderUI

protocol ApplicationsCoordinatorProtocol: AnyObject {
    func applicationsDidLoad(_ applications: [Application])
    func performAction(_ action: ApplicationAction?, for application: Application)
}

public class ApplicationsCoordinator: CoreInjectionNavigationCoordinator, ApplicationsCoordinatorProtocol {
    
    var applications = [Application]()
    var networkConfig: NetworkConfig { injected.networkConfig }
    
    lazy var applicationsViewController: UIViewController = {
        let service = ApplicationsService(networkConfig: networkConfig)
        let presenter = ApplicationsPresenter(
            coordinator: self,
            service: service,
            isCandidateSignedIn: self.isCandidateSignedIn)
        let vc = ApplicationsViewController(coordinator: self, presenter: presenter)
        return vc
    }()
    
    func isCandidateSignedIn() -> Bool {
        return injected.userRepository.loadAccessToken() != nil
    }
    
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
        case .viewOffer: showOfferViewer(for: application)
        case .acceptOffer: break
        case .declineOffer: break
        }
    }
    
    func showOfferViewer(for application: Application) {
        let service = OfferService(networkConfig: networkConfig)
        let presenter = OfferPresenter(coordinator: self, application: application, service: service)
        let vc = OfferViewController(coordinator: self, presenter: presenter)
        navigationRouter.push(viewController: vc, animated: true)
    }
    
    func showApplicationDetailViewer(for application: Application) {
        let service = ApplicationDetailService(networkConfig: networkConfig)
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



