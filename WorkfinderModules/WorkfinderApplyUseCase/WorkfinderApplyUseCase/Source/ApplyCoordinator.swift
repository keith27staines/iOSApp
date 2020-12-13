
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

let __bundle = Bundle(identifier: "com.workfinder.WorkfinderApplyUseCase")!

public protocol ApplyCoordinatorDelegate : class {
    func applicationDidFinish(preferredDestination: PreferredDestination)
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
    var applicationSource: ApplicationSource = .searchTab
    
    public var coverLetterPrimaryButtonText: String {
        let candidate = injected.userRepository.loadCandidate()
        guard let candidateUuid = candidate.uuid, !candidateUuid.isEmpty else {
            return NSLocalizedString("Next", comment: "")
        }
        return NSLocalizedString("Submit application", comment: "")
    }

    lazy var successPopup: SuccessPopupView = {
        return SuccessPopupView(leftButtonTapped: { [weak self] in
            self?.removeApplicationSubmittedSuccessfully()
            self?.applyCoordinatorDelegate?.applicationDidFinish(preferredDestination: .applications)
        }) { [weak self] in
            self?.removeApplicationSubmittedSuccessfully()
            self?.applyCoordinatorDelegate?.applicationDidFinish(preferredDestination: .search)
        }
    }()
    
    private func showApplicationSubmittedSuccessfully() {
        guard let window = UIApplication.shared.keyWindow
            else { return }
        let log = injected.log
        log.track(TrackingEvent(type: .applyComplete))
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
    
    let association: ExpandedAssociation
    let workplace: Workplace
    let updateCandidateService: UpdateCandidateServiceProtocol
    public init(applyCoordinatorDelegate: ApplyCoordinatorDelegate? = nil,
                updateCandidateService: UpdateCandidateServiceProtocol,
                applyService: PostPlacementServiceProtocol,
                workplace: Workplace,
                association: ExpandedAssociation,
                parent: CoreInjectionNavigationCoordinator?,
                navigationRouter: NavigationRoutingProtocol,
                inject: CoreInjectionProtocol,
                environment: EnvironmentType) {
        self.applyCoordinatorDelegate = applyCoordinatorDelegate
        self.applyService = applyService
        self.updateCandidateService = updateCandidateService
        self.environment = environment
        self.startingViewController = navigationRouter.navigationController.topViewController
        self.workplace = workplace
        self.association = association
        super.init(parent: parent, navigationRouter: navigationRouter, inject: inject)
        draftPlacementLogic.update(associationUuid: association.uuid)
    }
    
    override public func start() {
        super.start()
        log.track(TrackingEvent(type: .uc_apply_start(.searchTab)))
        startDateOfBirthIfNecessary()
    }
    
    func startDateOfBirthIfNecessary() {
        guard let dateOfBirthString = userRepository.loadCandidate().dateOfBirth,
            let dob = Date.workfinderDateStringToDate(dateOfBirthString)
            else {
            let dobVC = DateOfBirthCollectorViewController(coordinator: self)
            navigationRouter.push(viewController: dobVC, animated: true)
            return
        }
        onDidSelectDataOfBirth(date: dob)
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
    public func coverLetterDidCancel() {
        log.track(TrackingEvent(type: .uc_apply_cancel(applicationSource)))
    }
    public func coverLetterCoordinatorDidComplete(
        coverLetterText: String,
        picklistsDictionary: PicklistsDictionary) {
        self.picklistsDictionary = picklistsDictionary
        self.draftPlacementLogic.update(coverletter: coverLetterText)
        self.draftPlacementLogic.update(picklists: picklistsDictionary)
        self.startSigninCoordinatorIfNecessary()
    }
    
    func submitApplication() {
        let navigationController = navigationRouter.navigationController
        guard let messageHandler = coverletterCoordinator?.messageHandler
            else { return }
        let draft = draftPlacementLogic.draft
        applicationSubmitter = ApplicationSubmitter(
            applyService: applyService,
            draft: draft,
            navigationController: navigationController,
            messageHandler: messageHandler,
            onSuccess: { placementUuid in
                self.log.track(TrackingEvent(type: .uc_apply_convert(self.applicationSource)))
                self.addSupportingDocument(placementUuid)
            },
            onCancel: {
                self.cancelButtonWasTapped(sender: self)
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
        submitApplication()
    }
}

public class ApplicationSubmitter {
    private var draft: Placement
    private let applyService: PostPlacementServiceProtocol
    private weak var navigationController: UINavigationController?
    private var onSuccess: (F4SUUID) -> Void
    private var onCancel: () -> Void
    private weak var messageHandler: UserMessageHandler?
    
    init(
        applyService: PostPlacementServiceProtocol,
        draft: Placement,
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
    
    func cancelButtonWasTapped(sender: Any?) {
        cleanup()
        navigationRouter.pop(animated: true)
        parentCoordinator?.childCoordinatorDidFinish(self)
    }
    
    func cleanup(animated: Bool = true) {
        childCoordinators = [:]
    }

}

extension ApplyCoordinator: DateOfBirthCoordinatorProtocol {
    
    func onDidCancel() {
    }
    
    func onDidSelectDataOfBirth(date: Date) {
        var candidate = userRepository.loadCandidate()
        candidate.dateOfBirth = date.workfinderDateString
        userRepository.save(candidate: candidate)
        if candidate.uuid != nil {
            // persist the candidate's dob to the server
            updateCandidateService.update(candidate: candidate) { (result) in
        
            }
        }
        startCoverLetterCoordinator(candidateAge: candidate.age() ?? 0)
    }
}
