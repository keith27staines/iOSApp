
import Foundation
import WorkfinderCommon
import WorkfinderAppLogic
import WorkfinderCoordinators
import WorkfinderAcceptUseCase
import WorkfinderDocumentUploadUseCase

let __bundle = Bundle(identifier: "com.f4s.WorkfinderMessagesUseCase")!

public class TimelineCoordinator : CoreInjectionNavigationCoordinator, CompanyCoordinatorParentProtocol {
    
    var company: Company?
    let companyCoordinatorFactory: CompanyCoordinatorFactoryProtocol
    let companyRepository: F4SCompanyRepositoryProtocol
    let messageServiceFactory: F4SMessageServiceFactoryProtocol
    let messageActionServiceFactory: F4SMessageActionServiceFactoryProtocol
    let messageCannedResponsesServiceFactory: F4SCannedMessageResponsesServiceFactoryProtocol
    let offerProcessingService: F4SOfferProcessingServiceProtocol
    let companyDocumentsService: F4SCompanyDocumentServiceProtocol
    let placementDocumentsServiceFactory: F4SPlacementDocumentsServiceFactoryProtocol
    let documentUploaderFactory: F4SDocumentUploaderFactoryProtocol
    let placementService: F4SPlacementServiceProtocol
    let companyService: F4SCompanyServiceProtocol
    let roleService: F4SRoleServiceProtocol
    
    weak var tabBarCoordinator: TabBarCoordinatorProtocol?
    
    lazy var rootViewController: TimelineViewController = {
        let storyboard = UIStoryboard(name: "TimelineView", bundle: __bundle)
        let controller = storyboard.instantiateViewController(withIdentifier: "timelineViewCtrl") as! TimelineViewController
        controller.userStatusService = self.injected.userStatusService
        controller.placementService = self.placementService
        controller.log = self.injected.log
        return controller
    }()
    
    public init(parent: TabBarCoordinatorProtocol?,
                navigationRouter: NavigationRoutingProtocol,
                inject: CoreInjectionProtocol,
                messageServiceFactory: F4SMessageServiceFactoryProtocol,
                messageActionServiceFactory: F4SMessageActionServiceFactoryProtocol,
                messageCannedResponsesServiceFactory: F4SCannedMessageResponsesServiceFactoryProtocol,
                offerProcessingService: F4SOfferProcessingServiceProtocol,
                companyDocumentsService: F4SCompanyDocumentServiceProtocol,
                placementDocumentsServiceFactory: F4SPlacementDocumentsServiceFactoryProtocol,
                documentUploaderFactory: F4SDocumentUploaderFactoryProtocol,
                companyCoordinatorFactory: CompanyCoordinatorFactoryProtocol,
                companyRepository: F4SCompanyRepositoryProtocol,
                placementService: F4SPlacementServiceProtocol,
                companyService: F4SCompanyServiceProtocol,
                roleService: F4SRoleServiceProtocol) {
        self.messageServiceFactory = messageServiceFactory
        self.messageActionServiceFactory = messageActionServiceFactory
        self.messageCannedResponsesServiceFactory = messageCannedResponsesServiceFactory
        self.offerProcessingService = offerProcessingService
        self.companyDocumentsService = companyDocumentsService
        self.placementDocumentsServiceFactory = placementDocumentsServiceFactory
        self.documentUploaderFactory = documentUploaderFactory
        self.companyCoordinatorFactory = companyCoordinatorFactory
        self.companyRepository = companyRepository
        self.placementService = placementService
        self.companyService = companyService
        self.roleService = roleService
        self.tabBarCoordinator = parent
        super.init(parent: parent, navigationRouter: navigationRouter, inject: inject)
    }
    
    public override func start() {
        rootViewController.coordinator = self
        rootViewController.companyRepository = companyRepository
        navigationRouter.navigationController.pushViewController(rootViewController, animated: false)
    }
    
    func showCompanyDetails(parentCtrl: UIViewController, company: Company) {
        self.company = company
        assert(parentCtrl.navigationController != nil)
        guard let navigationController = parentCtrl.navigationController else { return }
        let navigationRouter = NavigationRouter(navigationController: navigationController)
        let companyCoordinator = companyCoordinatorFactory.makeCompanyCoordinator(parent: self, navigationRouter: navigationRouter, company: company, inject: injected)
        companyCoordinator.parentCoordinator = self
        addChildCoordinator(companyCoordinator)
        companyCoordinator.start()
    }
    
    func showMessageController(parentCtrl: UIViewController, threadUuid: String?, company: Company, placements: [F4STimelinePlacement], companies: [Company]) {
        let messageStoryboard = UIStoryboard(name: "Message", bundle: __bundle)
        guard let messageController = messageStoryboard.instantiateViewController(withIdentifier: "MessageContainerViewCtrl") as? MessageContainerViewController else {
            return
        }
        messageController.threadUuid = threadUuid
        messageController.company = company
        messageController.companies = companies
        messageController.placements = placements
        messageController.coordinator = self
        messageController.log = injected.log
        messageController.offerProcessor = offerProcessingService
        messageController.companyService = companyService
        messageController.roleService = roleService
        messageController.messageServiceFactory = messageServiceFactory
        parentCtrl.navigationController?.pushViewController(messageController, animated: true)
    }
    
    func makeMessageModelBuilder(threadUuid: F4SUUID) -> F4SMessageModelBuilder {
        let messageService = messageServiceFactory.makeMessageService(threadUuid: threadUuid)
        let actionService = messageActionServiceFactory.makeMessageActionService(threadUuid: threadUuid)
        let cannedService = messageCannedResponsesServiceFactory.makeCannedMessageResponsesService(threadUuid: threadUuid)
        return F4SMessageModelBuilder(threadUuid: threadUuid,
                                      messageService: messageService,
                                      messageActionService: actionService,
                                      messageCannedResponseService: cannedService)
    }
    
    func showAcceptOffer(acceptContext: AcceptOfferContext?) {
        guard let acceptContext = acceptContext else { return }
        let companyUuid = acceptContext.company.uuid
        let documentsModel = F4SCompanyDocumentsModel(companyUuid: companyUuid,
                                                      documentsService: companyDocumentsService)
        let acceptCoordinator = AcceptOfferCoordinator(
            parent: self,
            navigationRouter: navigationRouter,
            inject: injected,
            acceptContext: acceptContext,
            companyCoordinatorFactory: companyCoordinatorFactory,
            offerProcessor: offerProcessingService,
            companyDocumentsModel: documentsModel)
        addChildCoordinator(acceptCoordinator)
        acceptCoordinator.start()
    }
    
    func showAddDocuments(placement: F4STimelinePlacement?, company: Company?, action: F4SAction) {
        guard
            let placement = placement,
            let placementUuid = placement.placementUuid,
            let company = company,
            let requestModel = F4SBusinessLeadersRequestModel(action: action, placement: placement, company: company) else { return }
        let mode = UploadScenario.businessLeaderRequest(requestModel)
        let placementDocumentsService = placementDocumentsServiceFactory.makePlacementDocumentsService(placementUuid: placementUuid)
        let coordinator = DocumentUploadCoordinator(
            parent: self,
            navigationRouter: navigationRouter,
            inject: injected,
            mode: mode,
            placementUuid: placementUuid,
            documentService: placementDocumentsService,
            documentUploaderFactory: documentUploaderFactory)
        coordinator.didFinish = { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.navigationRouter.popToViewController(strongSelf.rootViewController, animated: true)
            print("What is supposed to happen here?")
        }
        addChildCoordinator(coordinator)
        coordinator.start()
    }
    
    func showExternalCompanySite(urlString: String?, acceptContext: AcceptOfferContext?) {
        guard
            let urlString = urlString,
            let url = URL(string: urlString),
            let _ = acceptContext else {
                injected.log.debug("acceptContext should not be nil", functionName: #function, fileName: #file, lineNumber: #line)
                return
        }
        UIApplication.shared.open(url, options: [:]) { (success) in
            // Nothing to do here yet
        }
    }
    
    public func updateUnreadCount(_ count: Int) {
        tabBarCoordinator?.updateUnreadMessagesCount(count)
    }
    
    public func showMessages() {
        tabBarCoordinator?.showMessages()
    }
    
    public func showSearch() {
        tabBarCoordinator?.showSearch()
    }
    
    func toggleMenu() {
        tabBarCoordinator?.toggleMenu(completion: nil)
    }
}


