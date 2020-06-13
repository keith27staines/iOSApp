
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
        workplace: Workplace,
        inject: CoreInjectionProtocol,
        applicationFinished: @escaping ((PreferredDestination) -> Void)
    ) -> CoreInjectionNavigationCoordinatorProtocol
}

protocol CompanyDetailsCoordinatorProtocol: CoreInjectionNavigationCoordinatorProtocol {
    var originScreen: ScreenName { get set }
    func companyDetailsPresenterDidFinish(_ presenter: CompanyDetailsPresenterProtocol)
    func companyDetailsPresenter(_ presenter: CompanyDetailsPresenterProtocol, requestedShowDuedilFor: Workplace)
    func companyDetailsPresenter(_ presenter: CompanyDetailsPresenterProtocol, requestOpenLink link: String)
    func applyTo(workplace: Workplace, hostLocationAssociation: HostAssociationJson)
    func onDidTapLinkedin(association: HostAssociationJson)
}

public class CompanyDetailsCoordinator : CoreInjectionNavigationCoordinator, CompanyDetailsCoordinatorProtocol, CompanyMainViewCoordinatorProtocol {
    public var originScreen = ScreenName.notSpecified
    let environment: EnvironmentType
    var companyViewController: CompanyDetailsViewController!
    var workplacePresenter: WorkplacePresenter!
    var workplace: Workplace
    var interestsRepository: F4SSelectedInterestsRepositoryProtocol
    let applyService: PostPlacementServiceProtocol
    let associationsProvider: AssociationsServiceProtocol

    var applicationFinishedWithPreferredDestination: ((PreferredDestination) -> Void)
    
    public init(
        parent: CompanyCoordinatorParentProtocol?,
        navigationRouter: NavigationRoutingProtocol,
        workplace: Workplace,
        inject: CoreInjectionProtocol,
        environment: EnvironmentType,
        interestsRepository: F4SSelectedInterestsRepositoryProtocol,
        applyService: PostPlacementServiceProtocol,
        associationsProvider: AssociationsServiceProtocol,
        applicationFinished: @escaping ((PreferredDestination) -> Void)) {
        self.environment = environment
        self.interestsRepository = interestsRepository
        self.workplace = workplace
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
            associationsProvider: associationsProvider,
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
    
    func applyTo(workplace: Workplace, hostLocationAssociation: HostAssociationJson) {
        guard let _ = workplacePresenter.selectedHost else { return }
        let applyCoordinator = ApplyCoordinator(
            applyCoordinatorDelegate: self,
            applyService: applyService,
            workplace: workplace,
            association: hostLocationAssociation,
            parent: self,
            navigationRouter: navigationRouter,
            inject: injected,
            environment: environment,
            interestsRepository: interestsRepository)
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
        openUrl(association.host.linkedinUrlString)
    }
    
    func onDidTapDuedil() {
        openUrl(workplace.companyJson.duedilUrlString)
    }
    
    func companyDetailsPresenter(_ presenter: CompanyDetailsPresenterProtocol, requestedShowDuedilFor workplace: Workplace) {
        guard
            let urlString = workplace.companyJson.duedilUrlString,
            let url = URL(string: urlString) else { return }
        openUrl(url)
    }
    
    func companyDetailsPresenter(_ presenter: CompanyDetailsPresenterProtocol, requestOpenLink link: String) {
        openUrl(link)
    }
}

