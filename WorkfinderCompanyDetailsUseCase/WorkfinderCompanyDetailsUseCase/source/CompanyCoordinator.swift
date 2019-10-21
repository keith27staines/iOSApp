
import UIKit
import WorkfinderCommon
import WorkfinderCoordinators
import WorkfinderAppLogic
import WorkfinderApplyUseCase

public class CompanyCoordinator : CoreInjectionNavigationCoordinator, CompanyCoordinatorProtocol {
    public var originScreen = ScreenName.notSpecified
    let environment: EnvironmentType
    let allowedToApplyLogic: AllowedToApplyLogicProtocol
    let applyService: F4SPlacementApplicationServiceProtocol
    var companyViewController: CompanyViewController!
    var companyViewModel: CompanyViewModel!
    var favouritesModel: CompanyFavouritesModel
    var company: Company
    var placementsRepository: F4SPlacementRepositoryProtocol
    var interestsRepository: F4SInterestsRepositoryProtocol
    let socialShareItemSource: SocialShareItemSource
    let getAllPlacementsService: F4SGetAllPlacementsServiceProtocol
    let emailVerificationModel: F4SEmailVerificationModelProtocol
    let documentServiceFactory: F4SPlacementDocumentsServiceFactoryProtocol
    let documentUploaderFactory: F4SDocumentUploaderFactoryProtocol
    let templateService: F4STemplateServiceProtocol
    let companyService: F4SCompanyServiceProtocol
    let companyDocumentsModel: F4SCompanyDocumentsModel

    weak var finishDespatcher: CompanyCoordinatorParentProtocol?
    
    public init(
        parent: CompanyCoordinatorParentProtocol?,
        navigationRouter: NavigationRoutingProtocol,
        company: Company,
        inject: CoreInjectionProtocol,
        environment: EnvironmentType,
        allowedToApplyLogic: AllowedToApplyLogicProtocol,
        placementsRepository: F4SPlacementRepositoryProtocol,
        interestsRepository: F4SInterestsRepositoryProtocol,
        socialShareItemSource: SocialShareItemSource,
        favouritesModel: CompanyFavouritesModel,
        templateService: F4STemplateServiceProtocol,
        getAllPlacementsService: F4SGetAllPlacementsServiceProtocol,
        emailVerificationModel: F4SEmailVerificationModelProtocol,
        documentServiceFactory: F4SPlacementDocumentsServiceFactoryProtocol,
        documentUploaderFactory: F4SDocumentUploaderFactoryProtocol,
        applyService: F4SPlacementApplicationServiceProtocol,
        companyService: F4SCompanyServiceProtocol,
        companyDocumentsModel: F4SCompanyDocumentsModel) {
        self.allowedToApplyLogic = allowedToApplyLogic
        self.environment = environment
        self.socialShareItemSource = socialShareItemSource
        self.interestsRepository = interestsRepository
        self.placementsRepository = placementsRepository
        self.company = company
        self.favouritesModel = favouritesModel
        self.templateService = templateService
        self.applyService = applyService
        self.finishDespatcher = parent
        self.getAllPlacementsService = getAllPlacementsService
        self.emailVerificationModel = emailVerificationModel
        self.documentServiceFactory = documentServiceFactory
        self.documentUploaderFactory = documentUploaderFactory
        self.companyService = companyService
        self.companyDocumentsModel = companyDocumentsModel
        super.init(parent: parent, navigationRouter: navigationRouter, inject: inject)
    }
    
    public override func start() {
        super.start()
        companyViewModel = CompanyViewModel(coordinatingDelegate: self,
                                            company: company,
                                            people: F4SHost.makeHosts(),
                                            companyService: companyService,
                                            favouritingModel: favouritesModel,
                                            allowedToApplyLogic: allowedToApplyLogic,
                                            companyDocumentsModel: companyDocumentsModel,
                                            log: injected.log)
        companyViewController = CompanyViewController(viewModel: companyViewModel)
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

extension CompanyCoordinator : CompanyViewModelCoordinatingDelegate {

    func companyViewModelDidComplete(_ viewModel: CompanyViewModel) {
        cleanup()
        navigationRouter.pop(animated: true)
        parentCoordinator?.childCoordinatorDidFinish(self)
    }
    
    func cleanup() {
        companyViewController = nil
        companyViewModel = nil
        childCoordinators = [:]
    }
    
    func companyViewModel(_ viewModel: CompanyViewModel, applyTo companyViewData: CompanyViewData, continueFrom placement: F4STimelinePlacement?) {
        let viewData = CompanyViewData(company: company)
        startApplyCoordinator(companyViewData: viewData, continueFrom: placement)
    }
    
    func startApplyCoordinator(companyViewData: CompanyViewData,
                               continueFrom: F4STimelinePlacement?) {
        let applyCoordinator = ApplyCoordinator(
            applyCoordinatorDelegate: self,
            company: company,
            parent: self,
            navigationRouter: navigationRouter,
            inject: injected,
            environment: environment,
            placementService: applyService,
            templateService: templateService,
            placementRepository: placementsRepository,
            interestsRepository: interestsRepository,
            getAllPlacementsService: getAllPlacementsService,
            emailVerificationModel: emailVerificationModel,
            documentServiceFactory: documentServiceFactory,
            documentUploaderFactory: documentUploaderFactory)
        addChildCoordinator(applyCoordinator)
        applyCoordinator.start()
    }
    
    func companyViewModel(_ viewModel: CompanyViewModel, requestsShowLinkedIn person: F4SHost) {
        print("Show linkedIn profile for \(person.displayName)")
    }
    
    func companyViewModel(_ viewModel: CompanyViewModel, requestsShowLinkedIn company: CompanyViewData) {
        openUrl(company.linkedinUrl)
    }
    
    func companyViewModel(_ viewModel: CompanyViewModel, requestedShowDuedil company: CompanyViewData) {
        openUrl(company.duedilUrl)
    }
    
    func companyViewModel(_ viewModel: CompanyViewModel, showShare company: CompanyViewData) {
        socialShareItemSource.company = self.company
        let activityViewController = UIActivityViewController(activityItems: [socialShareItemSource], applicationActivities: nil)
        activityViewController.completionWithItemsHandler = { [weak self] activityType, completed, items, error in
            guard let log = self?.injected.log else { return }
            switch completed {
            case true:
                log.track(event: .companyDetailsShareCompleted, properties: nil)
            case false:
                log.track(event: .companyDetailsShareCancelled, properties: nil)
            }
        }
        companyViewController.present(activityViewController, animated: true, completion: nil)
    }
}

