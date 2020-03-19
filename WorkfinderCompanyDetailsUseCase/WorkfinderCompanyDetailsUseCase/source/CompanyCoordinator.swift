
import UIKit
import WorkfinderCommon
import WorkfinderCoordinators
import WorkfinderAppLogic
import WorkfinderApplyUseCase

public class CompanyCoordinator : CoreInjectionNavigationCoordinator, CompanyCoordinatorProtocol {
    public var originScreen = ScreenName.notSpecified
    let environment: EnvironmentType
    var companyViewController: CompanyViewController!
    var companyWorkplacePresenter: CompanyWorkplacePresenter!
    var companyWorkplace: CompanyWorkplace
    var interestsRepository: F4SInterestsRepositoryProtocol
    let emailVerificationModel: F4SEmailVerificationModelProtocol
    let documentServiceFactory: F4SPlacementDocumentsServiceFactoryProtocol
    let documentUploaderFactory: F4SDocumentUploaderFactoryProtocol
    let templateService: F4STemplateServiceProtocol
    let applyService: ApplyServiceProtocol
    let companyService: F4SCompanyServiceProtocol

    weak var finishDespatcher: CompanyCoordinatorParentProtocol?
    
    public init(
        parent: CompanyCoordinatorParentProtocol?,
        navigationRouter: NavigationRoutingProtocol,
        companyWorkplace: CompanyWorkplace,
        inject: CoreInjectionProtocol,
        environment: EnvironmentType,
        interestsRepository: F4SInterestsRepositoryProtocol,
        templateService: F4STemplateServiceProtocol,
        emailVerificationModel: F4SEmailVerificationModelProtocol,
        documentServiceFactory: F4SPlacementDocumentsServiceFactoryProtocol,
        documentUploaderFactory: F4SDocumentUploaderFactoryProtocol,
        applyService: ApplyServiceProtocol,
        companyService: F4SCompanyServiceProtocol) {
        self.environment = environment
        self.interestsRepository = interestsRepository
        self.companyWorkplace = companyWorkplace
        self.templateService = templateService
        self.finishDespatcher = parent
        self.emailVerificationModel = emailVerificationModel
        self.documentServiceFactory = documentServiceFactory
        self.documentUploaderFactory = documentUploaderFactory
        self.applyService = applyService
        self.companyService = companyService
        super.init(parent: parent, navigationRouter: navigationRouter, inject: inject)
    }
    
    public override func start() {
        super.start()
        companyWorkplacePresenter = CompanyWorkplacePresenter(
            coordinatingDelegate: self,
            companyWorkplace: companyWorkplace,
            companyService: companyService,
            log: injected.log)
        companyViewController = CompanyViewController(
            viewModel: companyWorkplacePresenter, appSettings: injected.appSettings)
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

extension CompanyCoordinator : CompanyWorkplacePresenterCoordinatingDelegate {

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
    
    func companyWorkplacePresenter(_ presenter: CompanyWorkplacePresenter, applyTo companyWorkplace: CompanyWorkplace) {
        let host = presenter.selectedHost
        startApplyCoordinator(companyWorkplace: companyWorkplace, host: host)
    }
    
    func startApplyCoordinator(companyWorkplace: CompanyWorkplace,
                               host: F4SHost?) {
        let applyCoordinator = ApplyCoordinator(
            applyCoordinatorDelegate: self,
            applyService: applyService,
            companyWorkplace: companyWorkplace,
            host: host,
            parent: self,
            navigationRouter: navigationRouter,
            inject: injected,
            environment: environment,
            templateService: templateService,
            interestsRepository: interestsRepository,
            emailVerificationModel: emailVerificationModel,
            documentServiceFactory: documentServiceFactory,
            documentUploaderFactory: documentUploaderFactory)
        addChildCoordinator(applyCoordinator)
        applyCoordinator.start()
    }
    
    func companyWorkplacePresenter(_ viewModel: CompanyWorkplacePresenter, requestsShowLinkedInFor host: F4SHost) {
        guard let _ = host.profileUrl else { return }
        openUrl(host.profileUrl!)
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

