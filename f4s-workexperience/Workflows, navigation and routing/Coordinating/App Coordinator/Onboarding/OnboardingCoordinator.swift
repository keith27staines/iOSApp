//
//  OnboardingCoordinator.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 15/02/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import UIKit

protocol OnboardingCoordinatorProtocol : Coordinating {
    var hideOnboardingControls: Bool { get set }
    var delegate: OnboardingCoordinatorDelegate? { get set }
    var onboardingDidFinish: ((OnboardingCoordinatorProtocol) -> Void)? { get set }
}

protocol OnboardingCoordinatorDelegate : class {
    func shouldEnableLocation(_ :Bool)
}

class OnboardingCoordinator : NavigationCoordinator, OnboardingCoordinatorProtocol {
    
    weak var delegate: OnboardingCoordinatorDelegate?
    weak var onboardingViewController: OnboardingViewController?
    weak var partnerSelectionViewController: PartnerSelectionViewController?
    
    var onboardingDidFinish: ((OnboardingCoordinatorProtocol) -> Void)?
    
    var hideOnboardingControls: Bool = true {
        didSet {
            onboardingViewController?.hideOnboardingControls = hideOnboardingControls
        }
    }
    
    override func start() {
        let onboardingViewController = UIStoryboard(name: "Onboarding", bundle: nil).instantiateViewController(withIdentifier: "OnboardingViewController") as! OnboardingViewController
        self.onboardingViewController = onboardingViewController
        onboardingViewController.hideOnboardingControls = hideOnboardingControls
        onboardingViewController.shouldEnableLocation = { [weak self] enable in
            self?.delegate?.shouldEnableLocation(enable)
            self?.showPartnerList()
        }
        navigationRouter.present(onboardingViewController, animated: false, completion: nil)
    }
    
    func showPartnerList() {
        let vc = UIStoryboard(name: "SelectPartner", bundle: Bundle.main).instantiateInitialViewController() as! PartnerSelectionViewController
        partnerSelectionViewController = vc
        vc.doneButtonTapped = { [weak self] in
            guard let strongSelf = self else { return }
            F4SUser().didFinishOnboarding()
            strongSelf.onboardingDidFinish?(strongSelf)
        }
        onboardingViewController?.present(vc, animated: true, completion: nil)
    }
}
