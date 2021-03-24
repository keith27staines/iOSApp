//
//  AddressCaptureCoordinator.swift
//  WorkfinderCoordinators
//
//  Created by Keith Staines on 18/03/2021.
//  Copyright © 2021 Workfinder. All rights reserved.
//

import Foundation
import WorkfinderCommon
import WorkfinderServices
import WorkfinderCoordinators

public class AddressCaptureCoordinator: CoreInjectionNavigationCoordinator {
    
    var completion: (() -> Void)?
    var hidesBackButton: Bool
    
    public override func start() {
        let vc = AddressCaptureViewController(
            hideBackButton: hidesBackButton,
            updateCandidateService: UpdateCandidateService(networkConfig: injected.networkConfig),
            candidateRepository: injected.userRepository,
            onComplete: completion ?? {}
        )
        navigationRouter.push(viewController: vc, animated: true)
    }
    
    public init(
        parent: Coordinating?,
        navigationRouter: NavigationRoutingProtocol,
        inject: CoreInjectionProtocol,
        hidesBackButton: Bool,
        completion: @escaping () -> Void
    ) {
        self.completion = completion
        self.hidesBackButton = hidesBackButton
        super.init(parent: parent, navigationRouter: navigationRouter, inject: inject)
    }
}
