
import WorkfinderCommon
import WorkfinderCoordinators
import WorkfinderUI
import WorkfinderServices

protocol ApplicationsCoordinatorProtocol: AnyObject {
    func applicationsDidLoad(_ applications: [Application])
    func performAction(_ action: ApplicationAction?, for application: Application)
    func showCompanyHost(application: Application)
    func showCompany(application: Application)
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
        let applicationService = ApplicationDetailService(networkConfig: networkConfig)
        let presenter = ApplicationDetailPresenter(
            coordinator: self,
            applicationService: applicationService,
            application: application)
        let vc = ApplicationDetailViewController(
            coordinator: self,
            presenter: presenter)
        navigationRouter.push(viewController: vc, animated: true)
    }
    
    func showCompany(application: Application) {
        let companyService = CompanyService(networkConfig: networkConfig)
        let associationsService = AssociationsService(networkConfig: networkConfig)
        let presenter = CompanyViewPresenter(
            coordinator: self,
            application: application,
            companyService: companyService,
            associationsService: associationsService)
        let vc = CompanyViewController(presenter: presenter)
        navigationRouter.push(viewController: vc, animated: true)
    }
    
    func showCompanyHost(application: Application) {
        guard let associationUuid = application.associationUuid else { return }
        let hostService = HostsProvider(networkConfig: networkConfig)
        let hostLocationService = AssociationsService(networkConfig: networkConfig)
        let presenter = HostViewPresenter(
            coordinator: self,
            hostService: hostService,
            hostLocationService: hostLocationService,
            associationUuid: associationUuid)
        let vc = HostViewController(presenter: presenter)
        navigationRouter.push(viewController: vc, animated: true)
    }
}






