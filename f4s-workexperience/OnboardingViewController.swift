//
//  OnboardingViewController.swift
//  f4s-workexperience
//
//  Created by Sergiu Simon on 09/11/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController {

    var hideOnboardingControls: Bool = true {
        didSet {
            descriptionLabel.isHidden = hideOnboardingControls
            enterLocationButton.isHidden = hideOnboardingControls
            enableLocationButton.isHidden = hideOnboardingControls
        }
    }
    
    @IBOutlet weak var gradientView: UIView!
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
        view.backgroundColor = splashColor
        adjustNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupAppearance()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
    }
}

// MARK: - adjust appereance
extension OnboardingViewController {
    func adjustNavigationBar() {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    func setUpButtons() {

        let enableLocationText = NSLocalizedString("Enable location to find opportunities", comment: "")
        let enterLocationText = NSLocalizedString("Enter location manually", comment: "")
        enableLocationButton.isHidden = hideOnboardingControls
        enterLocationButton.isHidden = hideOnboardingControls
        
        enableLocationButton.setTitle(enableLocationText, for: .normal)
        enterLocationButton.setTitle(enterLocationText, for: .normal)
        let skinner = Skinner()
        skinner.apply(buttonSkin: skin?.primaryButtonSkin, to: enableLocationButton)
        skinner.apply(buttonSkin: skin?.secondaryButtonSkin, to: enterLocationButton)
    }

    func setupLabels() {
        let descriptionText = NSLocalizedString("Helping you find work", comment: "")
        descriptionLabel.attributedText = NSAttributedString(string: descriptionText, attributes: [NSAttributedStringKey.font: UIFont.f4sSystemFont(size: Style.hugeTextSize, weight: UIFont.Weight.thin), NSAttributedStringKey.foregroundColor: UIColor.white])
    }

    func setupAppearance() {
        UIApplication.shared.statusBarStyle = .lightContent
        switch Config.environment {
        case .staging:
            view.backgroundColor = RGBA.workfinderStagingGold.uiColor
        case .production:
            _ = UIView.gradient(view: gradientView, colorTop: UIColor(netHex: Colors.blueGradientTop).cgColor, colorBottom: UIColor(netHex: Colors.BlueGradientBottom).cgColor)
        }

        view.layoutSubviews()
        setUpButtons()
        setupLabels()
    }
}

// MARK: - user interraction
extension OnboardingViewController {
    @IBAction func enterLocationButton(_: AnyObject) {
        CustomNavigationHelper.sharedInstance.completeOnboarding(mapShouldRequestLocation: false)
    }

    @IBAction func enableLocationButton(_: AnyObject) {
        CustomNavigationHelper.sharedInstance.completeOnboarding(mapShouldRequestLocation: true)
    }
}
