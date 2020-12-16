
import UIKit
import WorkfinderCommon
import WorkfinderServices
import WorkfinderCoordinators
import WorkfinderAppLogic
import WorkfinderApplyUseCase

public protocol CompanyCoordinatorFactoryProtocol {
    
    func buildCoordinator(
        parent: CompanyCoordinatorParentProtocol,
        navigationRouter: NavigationRoutingProtocol,
        companyAndPin: CompanyAndPin,
        recommendedAssociationUuid: F4SUUID?,
        inject: CoreInjectionProtocol,
        applicationFinished: @escaping ((PreferredDestination) -> Void)
    ) -> CoreInjectionNavigationCoordinatorProtocol
}

protocol CompanyDetailsCoordinatorProtocol: CoreInjectionNavigationCoordinatorProtocol {
    var originScreen: ScreenName { get set }
    func companyDetailsPresenterDidFinish(_ presenter: CompanyDetailsPresenterProtocol)
    func companyDetailsPresenter(_ presenter: CompanyDetailsPresenterProtocol, requestedShowDuedilFor: CompanyAndPin)
    func companyDetailsPresenter(_ presenter: CompanyDetailsPresenterProtocol, requestOpenLink link: String)
    func applyTo(workplace: CompanyAndPin, association: HostAssociationJson)
    func onDidTapLinkedin(association: HostAssociationJson)
}

public class CompanyDetailsCoordinator : CoreInjectionNavigationCoordinator, CompanyDetailsCoordinatorProtocol, CompanyMainViewCoordinatorProtocol {
    public var originScreen = ScreenName.notSpecified
    let environment: EnvironmentType
    var companyViewController: CompanyDetailsViewController!
    var workplacePresenter: WorkplacePresenter!
    var workplace: CompanyAndPin
    var recommendedAssociationUuid: F4SUUID?
    let applyService: PostPlacementServiceProtocol
    let associationsProvider: AssociationsServiceProtocol

    var applicationFinishedWithPreferredDestination: ((PreferredDestination) -> Void)
    
    public init(
        parent: CompanyCoordinatorParentProtocol?,
        navigationRouter: NavigationRoutingProtocol,
        workplace: CompanyAndPin,
        recommendedAssociationUuid: F4SUUID?,
        inject: CoreInjectionProtocol,
        environment: EnvironmentType,
        applyService: PostPlacementServiceProtocol,
        associationsProvider: AssociationsServiceProtocol,
        applicationFinished: @escaping ((PreferredDestination) -> Void)) {
        self.environment = environment
        self.workplace = workplace
        self.recommendedAssociationUuid = recommendedAssociationUuid
        self.applyService = applyService
        self.associationsProvider = associationsProvider
        self.applicationFinishedWithPreferredDestination = applicationFinished
        super.init(parent: parent, navigationRouter: navigationRouter, inject: inject)
    }
    
    public override func start() {
        super.start()
        workplacePresenter = WorkplacePresenter(
            coordinator: self,
            workplace: workplace,
            recommendedAssociationUuid: recommendedAssociationUuid,
            associationsService: associationsProvider,
            log: injected.log)
        companyViewController = CompanyDetailsViewController(
            presenter: workplacePresenter)
        companyViewController.log = self.injected.log
        companyViewController.originScreen = originScreen
        navigationRouter.push(viewController: companyViewController, animated: true)
    }
    
    deinit {
        print("*************** Company coordinator was deinitialized")
    }
}

extension CompanyDetailsCoordinator : ApplyCoordinatorDelegate {
    public func applicationDidFinish(preferredDestination: PreferredDestination) {
        applicationFinishedWithPreferredDestination(preferredDestination)
        cleanup()
        navigationRouter.pop(animated: true)
        parentCoordinator?.childCoordinatorDidFinish(self)
    }
    public func applicationDidCancel() {
        cleanup()
        navigationRouter.pop(animated: true)
    }
}

extension CompanyDetailsCoordinator {
    
    func applyTo(workplace: CompanyAndPin, association: HostAssociationJson) {
        guard let _ = workplacePresenter.selectedHost else { return }
        let applyCoordinator = ApplyCoordinator(
            applyCoordinatorDelegate: self,
            updateCandidateService:UpdateCandidateService(networkConfig: injected.networkConfig),
            applyService: applyService,
            workplace: workplace,
            association: association,
            parent: self,
            navigationRouter: navigationRouter,
            inject: injected,
            environment: environment)
        addChildCoordinator(applyCoordinator)
        applyCoordinator.start()
    }

    func companyDetailsPresenterDidFinish(_ presenter: CompanyDetailsPresenterProtocol) {
        cleanup()
        navigationRouter.pop(animated: true)
        parentCoordinator?.childCoordinatorDidFinish(self)
    }
    
    func cleanup() {
        companyViewController = nil
        workplacePresenter = nil
        childCoordinators = [:]
    }
    
    func onDidTapLinkedin(association: HostAssociationJson) {
        openUrl(association.host?.linkedinUrlString)
    }
    
    func onDidTapDuedil() {
        openUrl(workplace.companyJson.duedilUrlString)
    }
    
    func companyDetailsPresenter(_ presenter: CompanyDetailsPresenterProtocol, requestedShowDuedilFor workplace: CompanyAndPin) {
        guard
            let urlString = workplace.companyJson.duedilUrlString,
            let url = URL(string: urlString) else { return }
        openUrl(url)
    }
    
    func companyDetailsPresenter(_ presenter: CompanyDetailsPresenterProtocol, requestOpenLink link: String) {
        openUrl(link)
    }
}

