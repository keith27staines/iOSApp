//
//  ProjectApplyBaseCoordinator.swift
//  WorkfinderProjectApply
//
//  Created by Keith on 01/09/2021.
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

public class ProjectApplyBaseCoordinator: CoreInjectionNavigationCoordinator {
    

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
    lazy var activeNavigationRouter: NavigationRoutingProtocol  = navigationRouter
    
    lazy public var errorHandler: ErrorHandlerProtocol = {
        ErrorHandler(
            navigationRouter: navigationRouter,
            coreInjection: self.injected,
            parentCoordinator: self)
    }()
    
    public init(
        parent: ProjectApplyCoordinatorDelegate?,
        navigationRouter: NavigationRoutingProtocol,
        inject: CoreInjectionProtocol,
        appSource: AppSource,
        switchToTab: ((TabIndex) -> Void)?
    ) {
        self.delegate = parent
        self.appSource = appSource
        self.switchToTab = switchToTab
        super.init(parent: parent, navigationRouter: navigationRouter, inject: inject)
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
    
    func onTapApply() {}
    
    func onModalFinished() {}
    
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
            navigationRouter: activeNavigationRouter,
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
            postcode.isEmpty else {
            // projectInfoPresenter.requiresCandidateLocation == true else {
            onPostcodeCaptureComplete()
            return
        }
        
        let coordinator = AddressCaptureCoordinator(
            parent: self,
            navigationRouter: activeNavigationRouter,
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
            navigationRouter: activeNavigationRouter,
            inject: injected,
            updateCandidateService: updateCandidateService
        ) { [weak self] in
            self?.submitApplication()
        }
        addChildCoordinator(dobCoordinator)
        dobCoordinator.start()
    }
    
    func submitApplication() {}
    
    func startLogin() {
        let coordinator = RegisterAndSignInCoordinator(
            parent: self,
            navigationRouter: activeNavigationRouter,
            inject: injected,
            firstScreenHidesBackButton: true,
            suppressDestinationAlertOnCompletion: true
        )
        addChildCoordinator(coordinator)
        coordinator.startLoginFirst()
    }
}

extension ProjectApplyBaseCoordinator: RegisterAndSignInCoordinatorParent {
    public func onCandidateIsSignedIn(preferredNextScreen: PreferredNextScreen) {
        captureNameIfNeccessary()
    }
    
    public func onRegisterAndSignInCancelled() {
        activeNavigationRouter.pop(animated: true)
    }
}


