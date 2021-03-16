//
//  DOBCaptureCoordinator.swift
//  WorkfinderApplyUseCase
//
//  Created by Keith Staines on 15/03/2021.
//  Copyright © 2021 Workfinder. All rights reserved.
//

import Foundation
import WorkfinderCommon
import WorkfinderServices

public class DOBCaptureCoordinator: CoreInjectionNavigationCoordinator, DateOfBirthCoordinatorProtocol {
    
    var onComplete: (() -> Void)?
    var updateCandidateService: UpdateCandidateServiceProtocol
    
    var candidate: Candidate {
        get { injected.userRepository.loadCandidate() }
        set { injected.userRepository.saveCandidate(newValue) }
    }
    
    public var isDOBCaptureRequired: Bool {
        let candidate = injected.userRepository.loadCandidate()
        return candidate.dateOfBirth == nil
    }
    
    public init(
        parent: Coordinating?,
        navigationRouter: NavigationRoutingProtocol,
        inject: CoreInjectionProtocol,
        updateCandidateService: UpdateCandidateServiceProtocol,
        onComplete: @escaping () -> Void
    ) {
        self.updateCandidateService = updateCandidateService
        self.onComplete = onComplete
        super.init(parent: parent, navigationRouter: navigationRouter, inject: inject)
    }
    
    public override func start() {
        guard isDOBCaptureRequired else {
            parentCoordinator?.childCoordinatorDidFinish(self)
            self.onComplete?()
            return
        }
        let vc = DateOfBirthCollectorViewController(coordinator: self, log: injected.log)
        navigationRouter.push(viewController: vc, animated: true)
    }
    
    public func onDidCancel() {
        navigationRouter.pop(animated: true)
        parentCoordinator?.childCoordinatorDidFinish(self)
    }
    
    public func onDidSelectDataOfBirth(date: Date) {
        let dobString = date.workfinderDateString
        candidate.dateOfBirth = dobString
        updateCandidateService.updateDOB(candidateUuid: self.candidate.uuid!, dobString: dobString) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let updatedCandidate):
                self.candidate = updatedCandidate
                //self.navigationRouter.pop(animated: true)
                self.parentCoordinator?.childCoordinatorDidFinish(self)
            case .failure(_):
                self.navigationRouter.pop(animated: true)
                self.parentCoordinator?.childCoordinatorDidFinish(self)
            }
            self.onComplete?()
        }
    }
}
