//
//  OnboardingViewController.swift
//  f4s-workexperience
//
//  Created by Sergiu Simon on 09/11/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import UIKit
import WorkfinderCommon
import WorkfinderUI

class OnboardingViewController: UIViewController {

    var hideOnboardingControls: Bool = true {
        didSet {
            _ = view
            descriptionLabel.isHidden = hideOnboardingControls
            enterLocationButton.isHidden = hideOnboardingControls
            enableLocationButton.isHidden = hideOnboardingControls
        }
    }
    
    var shouldEnableLocation: ((Bool) -> Void)?
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var enterLocationButton: UIButton!
    @IBOutlet weak var enableLocationButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionLabel.isHidden = true
        enterLocationButton.isHidden = true
        enableLocationButton.isHidden = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        adjustNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupAppearance()
    }
}

// MARK: - adjust appereance
extension OnboardingViewController {
    func adjustNavigationBar() {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    func setUpButtons() {
        enableLocationButton.isHidden = hideOnboardingControls
        enterLocationButton.isHidden = hideOnboardingControls
    }

    func setupAppearance() {
        styleNavigationController()
        setUpButtons()
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
}

// MARK: - user interraction
extension OnboardingViewController {
    @IBAction func enterLocationButton(_: AnyObject) {
        enterLocationButton.isEnabled = false
        shouldEnableLocation?(false)
    }

    @IBAction func enableLocationButton(_: AnyObject) {
        enterLocationButton.isEnabled = false
        shouldEnableLocation?(true)
    }
}
