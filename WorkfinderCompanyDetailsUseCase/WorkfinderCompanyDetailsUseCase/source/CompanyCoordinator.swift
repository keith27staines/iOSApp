
import UIKit
import WorkfinderCommon
import WorkfinderServices
import WorkfinderCoordinators
import WorkfinderAppLogic
import WorkfinderApplyUseCase

public class CompanyCoordinator : CoreInjectionNavigationCoordinator, CompanyCoordinatorProtocol {
    public var originScreen = ScreenName.notSpecified
    let environment: EnvironmentType
    var companyViewController: CompanyWorkplaceViewController!
    var companyWorkplacePresenter: CompanyWorkplacePresenter!
    var companyWorkplace: CompanyWorkplace
    var interestsRepository: F4SInterestsRepositoryProtocol
    let applyService: ApplyServiceProtocol
    let hostsProvider: HostsProviderProtocol

    weak var finishDespatcher: CompanyCoordinatorParentProtocol?
    
    public init(
        parent: CompanyCoordinatorParentProtocol?,
        navigationRouter: NavigationRoutingProtocol,
        companyWorkplace: CompanyWorkplace,
        inject: CoreInjectionProtocol,
        environment: EnvironmentType,
        interestsRepository: F4SInterestsRepositoryProtocol,
        applyService: ApplyServiceProtocol,
        hostsProvider: HostsProviderProtocol) {
        self.environment = environment
        self.interestsRepository = interestsRepository
        self.companyWorkplace = companyWorkplace
        self.finishDespatcher = parent
        self.applyService = applyService
        self.hostsProvider = hostsProvider
        super.init(parent: parent, navigationRouter: navigationRouter, inject: inject)
    }
    
    public override func start() {
        super.start()
        companyWorkplacePresenter = CompanyWorkplacePresenter(
            coordinator: self,
            companyWorkplace: companyWorkplace,
            hostsProvider: hostsProvider,
            log: injected.log)
        companyViewController = CompanyWorkplaceViewController(appSettings: injected.appSettings,
                                                               presenter: companyWorkplacePresenter)
        companyViewController.log = self.injected.log
        companyViewController.originScreen = originScreen
        navigationRouter.push(viewController: companyViewController, animated: true)
    }
    
    deinit {
        print("*************** Company coordinator was deinitialized")
    }
}

extension CompanyCoordinator : ApplyCoordinatorDelegate {
    public func applicationDidFinish(preferredDestination: ApplyCoordinator.PreferredDestinationAfterApplication) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.1) { [weak self] in
            guard let strongSelf = self else { return }
            switch preferredDestination {
            case .messages:
                self?.finishDespatcher?.showMessages()
            case .search:
                self?.finishDespatcher?.showSearch()
            case .none:
                break
            }
            strongSelf.cleanup()
            strongSelf.navigationRouter.pop(animated: true)
            strongSelf.parentCoordinator?.childCoordinatorDidFinish(strongSelf)
        }
    }
    public func applicationDidCancel() {
        cleanup()
        navigationRouter.pop(animated: true)
    }
}

extension CompanyCoordinator: CompanyWorkplaceCoordinatorProtocol {
    
    func applyTo(companyWorkplace: CompanyWorkplace, host: Host) {
        let applyCoordinator = ApplyCoordinator(
            applyCoordinatorDelegate: self,
            applyService: applyService,
            companyWorkplace: companyWorkplace,
            host: host,
            parent: self,
            navigationRouter: navigationRouter,
            inject: injected,
            environment: environment,
            interestsRepository: interestsRepository)
        addChildCoordinator(applyCoordinator)
        applyCoordinator.start()
    }

    func companyWorkplacePresenterDidFinish(_ presenter: CompanyWorkplacePresenter) {
        cleanup()
        navigationRouter.pop(animated: true)
        parentCoordinator?.childCoordinatorDidFinish(self)
    }
    
    func cleanup() {
        companyViewController = nil
        companyWorkplacePresenter = nil
        childCoordinators = [:]
    }
    
    func companyWorkplacePresenter(_ viewModel: CompanyWorkplacePresenter, requestsShowLinkedInFor host: Host) {
        guard let _ = host.linkedinUrlString else { return }
        openUrl(host.linkedinUrlString!)
    }
    
    func companyWorkplacePresenter(_ viewModel: CompanyWorkplacePresenter, requestsShowLinkedInFor company: CompanyWorkplace) {
        guard
            let urlString = companyWorkplace.companyJson.linkedInUrlString,
            let url = URL(string: urlString) else { return }
        openUrl(url)
    }
    
    func companyWorkplacePresenter(_ viewModel: CompanyWorkplacePresenter, requestedShowDuedilFor companyWorkplace: CompanyWorkplace) {
        guard
            let urlString = companyWorkplace.companyJson.duedilUrlString,
            let url = URL(string: urlString) else { return }
        openUrl(url)
    }
    
    func companyWorkplacePresenter(_ viewModel: CompanyWorkplacePresenter, requestOpenLink link: URL) {
        openUrl(link)
    }
}

