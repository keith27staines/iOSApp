
import WorkfinderCommon
import WorkfinderCoordinators
import WorkfinderUI
import WorkfinderServices

protocol ApplicationsCoordinatorProtocol: AnyObject {
    func applicationsDidLoad(_ applications: [Application])
    func performAction(_ action: ApplicationAction?, for application: Application, appSource: AppSource)
    func showCompanyHost(application: Application)
    func showCompany(application: Application)
    func routeToApplication(_ uuid: F4SUUID, appSource: AppSource)
}

public class ApplicationsCoordinator: CoreInjectionNavigationCoordinator, ApplicationsCoordinatorProtocol {
    
    var applications = [Application]()
    var networkConfig: NetworkConfig { injected.networkConfig }
    var log: F4SAnalyticsAndDebugging { injected.log }
    
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
    
    lazy var applicationDetailService: ApplicationDetailService = ApplicationDetailService(networkConfig: networkConfig)
    public func routeToApplication(_ uuid: F4SUUID, appSource: AppSource) {
        applicationDetailService.fetchApplication(placementUuid: uuid) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let application):
                switch application.state {
                case .offered, .accepted, .withdrawn:
                    self.showOfferViewer(for: application, appSource: appSource)

                default:
                    self.showApplicationDetailViewer(for: application, appSource: appSource)
                }
            case .failure(_):
                break
            }
        }
    }
    
    func performAction(
        _ action: ApplicationAction?,
        for application: Application,
        appSource: AppSource
    ) {
        guard let action = action else { return }
        switch action {
        case .viewApplication: showApplicationDetailViewer(for: application, appSource: appSource)
        case .viewOffer: showOfferViewer(for: application, appSource: appSource)
        case .acceptOffer: break
        case .declineOffer: break
        }
    }
    
    func showOfferViewer(for application: Application, appSource: AppSource) {
        let offerService = OfferService(networkConfig: networkConfig)
        let presenter = OfferPresenter(coordinator: self, application: application, offerService: offerService)
        let vc = OfferViewController(coordinator: self, presenter: presenter, log: log, appSource: appSource)
        navigationRouter.push(viewController: vc, animated: true)
    }
    
    var offerAwaitingDecision = false
    var offerDecisionMade = false
    
    func offerAccepted() {
        offerDecisionMade = true
    }
    
    func offerDeclined() {
        offerDecisionMade = true
    }
    
    func offerScreenCancelled() {
        //
    }
    
    func showApplicationDetailViewer(for application: Application, appSource: AppSource) {
        let applicationService = ApplicationDetailService(networkConfig: networkConfig)
        let presenter = ApplicationDetailPresenter(
            coordinator: self,
            applicationService: applicationService,
            application: application)
        let vc = ApplicationDetailViewController(
            coordinator: self,
            presenter: presenter,
            appSource: appSource,
            log: log
        )
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
        let locationService = AssociationsService(networkConfig: networkConfig)
        let presenter = HostViewPresenter(
            coordinator: self,
            hostService: hostService,
            locationService: locationService,
            associationUuid: associationUuid)
        let vc = HostViewController(presenter: presenter)
        navigationRouter.push(viewController: vc, animated: true)
    }
}






