//
//  OnboardingViewController.swift
//  f4s-workexperience
//
//  Created by Sergiu Simon on 09/11/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController {

    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var enterLocationButton: UIButton!
    @IBOutlet weak var enableLocationButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        adjustNavigationBar()
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
        UIApplication.shared.statusBarStyle = .lightContent
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.navigationBar.barTintColor = UIColor(netHex: Colors.black)
    }

    func setUpButtons() {

        let enableLocationText = NSLocalizedString("Enable location to find opportunities", comment: "")
        let enterLocationText = NSLocalizedString("Enter location manually", comment: "")

        enableLocationButton.setAttributedTitle(NSAttributedString(string: enableLocationText, attributes: [NSAttributedStringKey.font: UIFont.f4sSystemFont(size: Style.mediumTextSize, weight: UIFont.Weight.regular), NSAttributedStringKey.foregroundColor: UIColor.black]), for: .normal)
        enterLocationButton.setAttributedTitle(NSAttributedString(string: enterLocationText, attributes: [NSAttributedStringKey.font: UIFont.f4sSystemFont(size: Style.mediumTextSize, weight: UIFont.Weight.regular), NSAttributedStringKey.foregroundColor: UIColor.white]), for: .normal)

        enableLocationButton.backgroundColor = UIColor.white
        enterLocationButton.backgroundColor = UIColor.clear

        enableLocationButton.layer.cornerRadius = 10
        enterLocationButton.layer.cornerRadius = 10

        enterLocationButton.layer.borderColor = UIColor.white.cgColor
        enterLocationButton.layer.borderWidth = 0.5
    }

    func setupLabels() {
        let descriptionText = NSLocalizedString("Helping you find work", comment: "")
        descriptionLabel.attributedText = NSAttributedString(string: descriptionText, attributes: [NSAttributedStringKey.font: UIFont.f4sSystemFont(size: Style.hugeTextSize, weight: UIFont.Weight.thin), NSAttributedStringKey.foregroundColor: UIColor.white])
    }

    func setupAppearance() {
        UIApplication.shared.statusBarStyle = .lightContent
        gradientView = UIView.gradient(view: gradientView, colorTop: UIColor(netHex: Colors.blueGradientTop).cgColor, colorBottom: UIColor(netHex: Colors.BlueGradientBottom).cgColor)
        setUpButtons()
        setupLabels()
    }
}

// MARK: - user interraction
extension OnboardingViewController {
    @IBAction func enterLocationButton(_: AnyObject) {
        if let window = self.view.window {
            CustomNavigationHelper.sharedInstance.moveToMapCtrl(window: window, shouldRequestAuthorization: false)
        }
    }

    @IBAction func enableLocationButton(_: AnyObject) {
        if let window = self.view.window {
            CustomNavigationHelper.sharedInstance.moveToMapCtrl(window: window, shouldRequestAuthorization: true)
        }
    }
}
