
import Foundation
import WorkfinderCommon
import WorkfinderServices
import WorkfinderAppLogic
import WorkfinderUI
import WorkfinderCoordinators
import WorkfinderUserDetailsUseCase
import WorkfinderCoverLetter
import WorkfinderRegisterCandidate
import WorkfinderDocumentUpload
import WorkfinderCandidateProfile

let __bundle = Bundle(identifier: "com.workfinder.WorkfinderApplyUseCase")!

public protocol ApplyCoordinatorDelegate : AnyObject {
    func applicationDidFinish(preferredDestination: TabIndex)
    func applicationDidCancel()
}

public class ApplyCoordinator : CoreInjectionNavigationCoordinator, CoverLetterParentCoordinatorProtocol {
    var applicationSubmitter: ApplicationSubmitter?
    var userRepository: UserRepositoryProtocol { injected.userRepository }
    var coverletterCoordinator: CoverLetterFlow?
    var rootViewController: UIViewController?
    let environment: EnvironmentType
    let startingViewController: UIViewController!
    let applyService: PostPlacementServiceProtocol
    weak var applyCoordinatorDelegate: ApplyCoordinatorDelegate?
    lazy var draftPlacementLogic: DraftPlacementPreparer = {
        return DraftPlacementPreparer()
    }()
    var log: F4SAnalytics { injected.log }
    var picklistsDictionary: PicklistsDictionary?
    let appSource: AppSource
    let association: HostAssociationJson
    let workplace: CompanyAndPin
    let updateCandidateService: UpdateCandidateServiceProtocol
    var didCaptureDOB = false
    
    public var coverLetterPrimaryButtonText: String {
        let isCandidateSignedIn = injected.userRepository.isCandidateLoggedIn
        return isCandidateSignedIn ? NSLocalizedString("Submit application", comment: "") : NSLocalizedString("Next", comment: "")
    }

    lazy var successPopup: SuccessPopupView = {
        return SuccessPopupView(leftButtonTapped: { [weak self] in
            self?.finishApply(destination: .applications)
        }) { [weak self] in
            self?.finishApply(destination: .home)
        }
    }()
    
    private func showApplicationSubmittedSuccessfully() {
        guard let window = UIApplication.shared.keyWindow
            else { return }
        let navigationController = navigationRouter.navigationController
        window.addSubview(successPopup)
        navigationController.navigationBar.layer.zPosition = -1
        successPopup.frame = window.bounds
    }
    
    private func removeApplicationSubmittedSuccessfully() {
        successPopup.removeFromSuperview()
        let navigationController = navigationRouter.navigationController
        navigationController.navigationBar.layer.zPosition = 0
    }
    
    var isUserRegistrationWorkflowRequired: Bool {
        let userRepository = injected.userRepository
        let candidate = userRepository.loadCandidate()
        return candidate.uuid == nil
    }

    public init(applyCoordinatorDelegate: ApplyCoordinatorDelegate? = nil,
                updateCandidateService: UpdateCandidateServiceProtocol,
                applyService: PostPlacementServiceProtocol,
                workplace: CompanyAndPin,
                association: HostAssociationJson,
                parent: CoreInjectionNavigationCoordinator?,
                navigationRouter: NavigationRoutingProtocol,
                inject: CoreInjectionProtocol,
                environment: EnvironmentType,
                appSource: AppSource) {
        self.applyCoordinatorDelegate = applyCoordinatorDelegate
        self.applyService = applyService
        self.updateCandidateService = updateCandidateService
        self.environment = environment
        self.startingViewController = navigationRouter.navigationController.topViewController
        self.workplace = workplace
        self.association = association
        self.appSource = appSource
        self.rootViewController = navigationRouter.navigationController.topViewController
        super.init(parent: parent, navigationRouter: navigationRouter, inject: inject)
        draftPlacementLogic.update(associationUuid: association.uuid)
    }
    
    override public func start() {
        super.start()
        log.track(.passive_apply_start(appSource))
        log.track(.placement_funnel_start(appSource))
        startCoverLetterCoordinator(candidateAge: 18)
    }
    
    func startCoverLetterCoordinator(candidateAge: Int) {
        guard let hostName = association.host?.fullName else { return }
        let candidateName = injected.user.fullName
        let companyName = workplace.companyJson.name ?? "Unknown company"
        coverletterCoordinator = CoverLetterFlowFactory.makeFlow(
            type: .passiveApplication,
            parent: self,
            navigationRouter: navigationRouter,
            inject: injected,
            candidateAge: candidateAge,
            candidateName: candidateName,
            isProject: false,
            projectTitle: nil,
            companyName: companyName,
            hostName: hostName)
        coverletterCoordinator?.start()
    }
    
    public func coverLetterDidCancel() {
        switch didCaptureDOB {
        case true: break
        case false: cancelApply()
        }
    }
    public func coverLetterCoordinatorDidComplete(
        coverLetterText: String,
        picklistsDictionary: PicklistsDictionary) {
        self.picklistsDictionary = picklistsDictionary
        self.draftPlacementLogic.update(coverletter: coverLetterText)
        self.draftPlacementLogic.update(picklists: picklistsDictionary)
        self.startSigninCoordinatorIfNecessary()
    }
    
    func startSigninCoordinatorIfNecessary() {
        guard isUserRegistrationWorkflowRequired
            else {
            onCandidateIsSignedIn()
            return
        }
        let coordinator = RegisterAndSignInCoordinator(parent: self, navigationRouter: navigationRouter, inject: injected, firstScreenHidesBackButton: true)
        addChildCoordinator(coordinator)
        coordinator.start()
    }
    
    func captureDOBIfNecessary() {
        let updateCandidateService = UpdateCandidateService(networkConfig: injected.networkConfig)
        let dobCoordinator = DOBCaptureCoordinator(
            parent: self,
            navigationRouter: navigationRouter,
            inject: injected,
            updateCandidateService: updateCandidateService
        ) { [weak self] in
            self?.submitApplication()
        }
        addChildCoordinator(dobCoordinator)
        dobCoordinator.start()
    }
    
    func submitApplication() {
        guard let messageHandler = coverletterCoordinator?.messageHandler
            else { return }
        log.track(.placement_funnel_convert(appSource))
        let navigationController = navigationRouter.navigationController
        let draft = draftPlacementLogic.draft
        applicationSubmitter = ApplicationSubmitter(
            applyService: applyService,
            draft: draft,
            navigationController: navigationController,
            messageHandler: messageHandler,
            onSuccess: { placementUuid in
                self.addSupportingDocument(placementUuid)
            },
            onCancel: {
                self.cancelApply()
            })
        applicationSubmitter?.submitApplication()
    }
    
    func addSupportingDocument(_ placementUuid: F4SUUID) {
        guard userRepository.loadCandidate().age() ?? 0 >= 18 else {
            showApplicationSubmittedSuccessfully()
            return
        }
        let documentCoordinator = DocumentUploadCoordinator(
            parent: self,
            navigationRouter: navigationRouter,
            inject: injected,
            delegate: self,
            appModel: AppModel.placement,
            objectUuid: placementUuid,
            showBackButton: false
        )
        addChildCoordinator(documentCoordinator)
        documentCoordinator.start()
    }
    
    deinit { print("ApplyCoordinator did deinit") }
}

extension ApplyCoordinator: DocumentUploadCoordinatorParentProtocol {
    public func onSkipDocumentUpload() {
        showApplicationSubmittedSuccessfully()
    }
    
    public func onUploadComplete() {
        showApplicationSubmittedSuccessfully()
    }
}

extension ApplyCoordinator: RegisterAndSignInCoordinatorParent {
    
    public func onRegisterAndSignInCancelled() {
        navigationRouter.pop(animated: true)
        coverletterCoordinator?.messageHandler?.hideLoadingOverlay()
    }
    
    public func onCandidateIsSignedIn() {
        let uuid = userRepository.loadCandidate().uuid!
        draftPlacementLogic.update(candidateUuid: uuid)
        captureDOBIfNecessary()
    }
}

public class ApplicationSubmitter {
    private var draft: PostPlacementJson
    private let applyService: PostPlacementServiceProtocol
    private weak var navigationController: UINavigationController?
    private var onSuccess: (F4SUUID) -> Void
    private var onCancel: () -> Void
    private weak var messageHandler: UserMessageHandler?
    
    init(
        applyService: PostPlacementServiceProtocol,
        draft: PostPlacementJson,
        navigationController: UINavigationController,
        messageHandler: UserMessageHandler,
        onSuccess: @escaping (F4SUUID) -> Void,
        onCancel: @escaping () -> Void) {
        self.applyService = applyService
        self.draft = draft
        self.navigationController = navigationController
        self.messageHandler = messageHandler
        self.onSuccess = onSuccess
        self.onCancel = onCancel
    }
    
    public func submitApplication() {
        messageHandler?.showLightLoadingOverlay()
        applyService.postPlacement(draftPlacement: draft) { [weak self] (result) in
            guard
                let self = self,
                let messageHandler =  self.messageHandler
                else { return }
            switch result {
            case .success(let placement):
                guard let placementUuid = placement.uuid else {
                    return
                }
                self.onSuccess(placementUuid)
            case .failure(let error):
                messageHandler.displayOptionalErrorIfNotNil(
                    error,
                    cancelHandler: self.onCancel,
                    retryHandler: self.submitApplication)
            }
        }
    }
}

extension ApplyCoordinator {
    
    func cancelAfterUserDetails() {
        let alert = UIAlertController(title: "Already applied", message: "You have already applied to this company (perhaps on a different device", preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { [weak self] (action) in
            guard let strongSelf = self else { return }
            strongSelf.navigationRouter.popToViewController(strongSelf.rootViewController!, animated: false)
            strongSelf.applyCoordinatorDelegate?.applicationDidCancel()
            strongSelf.parentCoordinator?.childCoordinatorDidFinish(strongSelf)
        }
        alert.addAction(okAction)
        navigationRouter.present(alert, animated: true, completion: nil)
    }
    
    func finishApply(destination: TabIndex) {
        log.track(.passive_apply_convert(appSource))
        cleanup()
        parentCoordinator?.childCoordinatorDidFinish(self)
        self.applyCoordinatorDelegate?.applicationDidFinish(preferredDestination: destination)
        self.removeApplicationSubmittedSuccessfully()
        self.injected.requestAppReviewLogic.makeRequest()
    }
    
    func cancelApply() {
        log.track(.placement_funnel_cancel(appSource))
        log.track(.passive_apply_cancel(appSource))
        cleanup()
        parentCoordinator?.childCoordinatorDidFinish(self)
    }
    
    func cleanup(animated: Bool = true) {
        childCoordinators = [:]
    }

}
