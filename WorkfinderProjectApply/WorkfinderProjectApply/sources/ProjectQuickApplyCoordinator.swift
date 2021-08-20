//
//  ProjectQuickApplyCoordinator.swift
//  WorkfinderProjectApply
//
//  Created by Keith on 20/08/2021.
//  Copyright © 2021 Workfinder. All rights reserved.
//

import WorkfinderCommon
import WorkfinderCoordinators
import WorkfinderServices
import WorkfinderCoverLetter
import WorkfinderAppLogic
import WorkfinderDocumentUpload
import WorkfinderUI
import ErrorHandlingUI
import WorkfinderRegisterCandidate
import WorkfinderCandidateProfile
import StoreKit

public class ProjectQuickApplyCoordinator: CoreInjectionNavigationCoordinator {
    
    var projectInfoPresenter: ProjectInfoPresenter
    var switchToTab: ((TabIndex) -> Void)?
    weak var successViewController: UIViewController?
    var placementService: PostPlacementServiceProtocol?
    var delegate: ProjectApplyCoordinatorDelegate?
    var projectType: String = ""
    var log: F4SAnalyticsAndDebugging { injected.log }
    let appSource: AppSource
    var coverLetterText: String = ""
    var picklistsDictionary = PicklistsDictionary()
    weak var messageHandler: UserMessageHandler?
    weak var presentingViewController: UIViewController?
    
    lazy public var errorHandler: ErrorHandlerProtocol = {
        ErrorHandler(
            navigationRouter: navigationRouter,
            coreInjection: self.injected,
            parentCoordinator: self)
    }()
    
    public init(
        parent: ProjectApplyCoordinatorDelegate?,
        navigationRouter: NavigationRoutingProtocol,
        presentingViewController: UIViewController,
        inject: CoreInjectionProtocol,
        projectInfoPresenter: ProjectInfoPresenter,
        appSource: AppSource,
        switchToTab: ((TabIndex) -> Void)?
    ) {
        self.delegate = parent
        self.appSource = appSource
        self.switchToTab = switchToTab
        self.projectInfoPresenter = projectInfoPresenter
        self.presentingViewController = presentingViewController
        super.init(parent: parent, navigationRouter: navigationRouter, inject: inject)
    }
    
    public override func start() {
        let user = UserRepository().loadUser()
        let candidate = UserRepository().loadCandidate()
        let coordinator = CoverLetterFlowFactory.makeFlow(
            type: .projectApplication,
            parent: self,
            navigationRouter: navigationRouter,
            inject: injected,
            candidateAge: candidate.age() ?? 18,
            candidateName: user.fullname,
            isProject: true,
            projectTitle: projectInfoPresenter.projectName,
            companyName: projectInfoPresenter.companyName,
            hostName: projectInfoPresenter.hostName)
        addChildCoordinator(coordinator)
        coordinator.start()
        messageHandler = coordinator.messageHandler
    }
    
    func showAlert(title: String, message: String, buttonTitle: String) {
        guard
            let topVC = navigationRouter.navigationController.topViewController
            else { return }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancel = UIAlertAction(title: buttonTitle, style: .cancel, handler: nil)
        alert.addAction(cancel)
        topVC.present(alert, animated: true, completion: nil)
    }
}

extension ProjectQuickApplyCoordinator: ProjectApplyCoordinatorProtocol {
    
    func onTapApply() {
        // Nothing to do here because unlike ProjectApplyCoordinator in we aren't showing the project page and the apply process has already been initiated
    }
    
    func onModalFinished() {
        guard let presentingViewController = presentingViewController else { return }
        navigationRouter.popToViewController(presentingViewController, animated: true)
        delegate?.onProjectApplyDidFinish()
        parentCoordinator?.childCoordinatorDidFinish(self)
    }
    
    func onCoverLetterWorkflowCancelled() {
        log.track(.placement_funnel_cancel(appSource))
        log.track(.project_apply_cancel(appSource))
    }
    
    func onCoverLetterDidComplete() {
        switch UserRepository().isCandidateLoggedIn {
        case true: captureNameIfNeccessary()
        case false: startLogin()
        }
    }
    
    func onNameCaptureComplete() {
        capturePostcodeIfNecessary()
    }
    
    func onPostcodeCaptureComplete() {
        captureDOBIfNecessary()
    }
    
    func captureNameIfNeccessary() {
        guard NameCaptureCoordinator.isNameCaptureRequired else {
            onNameCaptureComplete()
            return
        }
        let coordinator = NameCaptureCoordinator(
            parent: self,
            navigationRouter: navigationRouter,
            inject: injected
        ) { [weak self] in
            self?.onNameCaptureComplete()
        }
        addChildCoordinator(coordinator)
        coordinator.start()
    }
    
    func capturePostcodeIfNecessary() {
        let postcode = UserRepository().loadCandidate().postcode ?? ""
        guard
            postcode.isEmpty,
            projectInfoPresenter.requiresCandidateLocation == true else {
            onPostcodeCaptureComplete()
            return
        }
        
        let coordinator = AddressCaptureCoordinator(
            parent: self,
            navigationRouter: navigationRouter,
            inject: injected,
            hidesBackButton: true
        ) { [weak self] in
            self?.onPostcodeCaptureComplete()
        }
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
    
    func startLogin() {
        let coordinator = RegisterAndSignInCoordinator(
            parent: self,
            navigationRouter: navigationRouter,
            inject: injected,
            firstScreenHidesBackButton: true)
        addChildCoordinator(coordinator)
        coordinator.startLoginFirst()
    }
    
    func submitApplication() {
        self.log.track(.placement_funnel_convert(self.appSource))
        // guard let vc = modalVC, let view = vc.view else { return }
        var picklistsDictionary = self.picklistsDictionary
        picklistsDictionary[.availabilityPeriod] = nil
        picklistsDictionary[.duration] = nil
        messageHandler?.showLoadingOverlay()
        placementService = PostPlacementService(networkConfig: injected.networkConfig)
        let builder = DraftPlacementPreparer()
        builder.update(candidateUuid: UserRepository().loadCandidate().uuid)
        builder.update(picklists: picklistsDictionary)
        builder.update(associationUuid: projectInfoPresenter.associationUuid)
        builder.update(associatedProject: projectInfoPresenter.projectUuid)
        builder.update(coverletter: coverLetterText)
        placementService = PostPlacementService(networkConfig: injected.networkConfig)
        placementService?.postPlacement(draftPlacement: builder.draft) { [weak self] (result) in
            guard let self = self else { return }
            self.messageHandler?.hideLoadingOverlay()
            switch result {
            case .success(let placement):
                self.log.track(.project_apply_convert(self.appSource))
                self.onApplicationSubmitted(placement: placement)
            case .failure(let error):
                self.messageHandler?.displayOptionalErrorIfNotNil(error, cancelHandler: {
                    // just dismiss
                }, retryHandler: {
                    self.submitApplication()
                })
            }
        }
    }
    
    func onApplicationSubmitted(placement: PostPlacementJson) {
        guard let placementUuid = placement.uuid else { return }
        let coordinator = DocumentUploadCoordinator(
            parent: self,
            navigationRouter: navigationRouter,
            inject: injected, delegate: self,
            appModel: .placement,
            objectUuid: placementUuid,
            showBackButton: false
        )
        addChildCoordinator(coordinator)
        coordinator.start()
    }
    
    func showSuccess() {
        let vc = SuccessViewController(
            applicationsButtonTap: { [weak self] in
                self?.dismissSuccessSwitchingTo(.applications)
        },
            searchButtonTap: { [weak self] in
                self?.dismissSuccessSwitchingTo(.home)
        })
        vc.modalPresentationStyle = .overCurrentContext
        navigationRouter.navigationController.topViewController?.present(vc, animated: false, completion: nil)
        successViewController = vc
    }
    
    func dismissSuccessSwitchingTo(_ tabIndex: TabIndex) {
        successViewController?.dismiss(animated: true, completion: nil)
        onModalFinished()
        switchToTab?(tabIndex)
        injected.requestAppReviewLogic.makeRequest()
    }
}

extension ProjectQuickApplyCoordinator: CoverLetterParentCoordinatorProtocol {
    public var coverLetterPrimaryButtonText: String { "Apply now!" }
    public func coverLetterDidCancel() {
        onCoverLetterWorkflowCancelled()
    }
    public func coverLetterCoordinatorDidComplete(coverLetterText: String, picklistsDictionary: PicklistsDictionary) {
        self.coverLetterText = coverLetterText
        self.picklistsDictionary = picklistsDictionary
        onCoverLetterDidComplete()
    }
}

extension ProjectQuickApplyCoordinator: DocumentUploadCoordinatorParentProtocol {
    public func onSkipDocumentUpload() {
        showSuccess()
    }
    
    public func onUploadComplete() {
        showSuccess()
    }
}

extension ProjectQuickApplyCoordinator: RegisterAndSignInCoordinatorParent {
    public func onCandidateIsSignedIn(preferredNextScreen: PreferredNextScreen) {
        capturePostcodeIfNecessary()
    }
    
    public func onRegisterAndSignInCancelled() {
        navigationRouter.pop(animated: true)
    }

}
