//
//  ProcessedMessagesViewController.swift
//  f4s-workexperience
//
//  Created by Alex Astilean on 07/12/2016.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import UIKit

class ProcessedMessagesViewController: UIViewController {

    @IBOutlet weak var addInfoButton: UIButton!
    @IBOutlet weak var receivedLabel: UILabel!
    @IBOutlet weak var extraInformationLabel: UILabel!

    var applicationContext: F4SApplicationContext?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// MARK: - user interaction
extension ProcessedMessagesViewController {
    @IBAction func addInfoButton(_: Any) {
        if let navigCtrl = self.navigationController, let _ = self.applicationContext?.company {
            CustomNavigationHelper.sharedInstance.pushExtraInfoViewController(navigCtrl: navigCtrl, applicationContext: applicationContext!)
        }
    }
}

// MARK: - appearance
extension ProcessedMessagesViewController {
    func setupAppearance() {
        self.navigationController?.navigationBar.isHidden = true
        setupAddInfoButton()
        setupLabels()
    }

    func setupAddInfoButton() {
        let addInfoText = NSLocalizedString("Add info", comment: "")
        addInfoButton.setBackgroundColor(color: UIColor(netHex: Colors.mediumGreen), forUIControlState: .normal)
        addInfoButton.setBackgroundColor(color: UIColor(netHex: Colors.lightGreen), forUIControlState: .highlighted)
        addInfoButton.setBackgroundColor(color: UIColor(netHex: Colors.whiteGreen), forUIControlState: .disabled)
        addInfoButton.setTitleColor(UIColor.white, for: .normal)
        addInfoButton.setTitleColor(UIColor.white, for: .highlighted)
        
        addInfoButton.layer.masksToBounds = true
        addInfoButton.layer.cornerRadius = 10
        addInfoButton.setAttributedTitle(NSAttributedString(string: addInfoText, attributes: [NSAttributedStringKey.font: UIFont.f4sSystemFont(size: Style.biggerMediumTextSize, weight: UIFont.Weight.regular), NSAttributedStringKey.foregroundColor: UIColor.white]), for: .normal)
    }

    func setupLabels() {
        let receivedLabelText = NSLocalizedString("Thanks, we've received your application for work experience at ", comment: "")

        let formattedString = NSMutableAttributedString()
        formattedString.append(NSAttributedString(string: receivedLabelText, attributes: [NSAttributedStringKey.font: UIFont.f4sSystemFont(size: Style.largeTextSize, weight: UIFont.Weight.regular), NSAttributedStringKey.foregroundColor: UIColor(netHex: Colors.black)]))
        if let currentCompanyName = applicationContext?.company?.name {
            formattedString.append(NSAttributedString(string: currentCompanyName, attributes: [NSAttributedStringKey.font: UIFont.f4sSystemFont(size: Style.largeTextSize, weight: UIFont.Weight.semibold), NSAttributedStringKey.foregroundColor: UIColor(netHex: Colors.black)]))
        }
        self.receivedLabel.attributedText = formattedString

        self.receivedLabel.numberOfLines = 0
        self.receivedLabel.sizeToFit()
        self.receivedLabel.textAlignment = .center

        let extraInformationText = NSLocalizedString("To complete your application we need a couple more bits of information", comment: "")
        self.extraInformationLabel.attributedText = NSAttributedString(string: extraInformationText, attributes: [NSAttributedStringKey.font: UIFont.f4sSystemFont(size: Style.largeTextSize, weight: UIFont.Weight.regular), NSAttributedStringKey.foregroundColor: UIColor(netHex: Colors.black)])

        self.extraInformationLabel.numberOfLines = 0
        self.extraInformationLabel.sizeToFit()
        self.receivedLabel.textAlignment = .center
    }
}
