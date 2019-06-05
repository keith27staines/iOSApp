//
//  ProcessedMessagesViewController.swift
//  f4s-workexperience
//
//  Created by Alex Astilean on 07/12/2016.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import UIKit
import WorkfinderCommon

protocol HalfWayHoorayCoordinatorProtocol : class {
    func halfWayHoorayDidFinish()
}

class HalfWayHoorayViewController: UIViewController {

    @IBOutlet weak var addInfoButton: UIButton!
    @IBOutlet weak var receivedLabel: UILabel!
    @IBOutlet weak var extraInformationLabel: UILabel!

    var companyViewData: CompanyViewData?
    var coordinator: HalfWayHoorayCoordinatorProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// MARK: - user interaction
extension HalfWayHoorayViewController {
    @IBAction func addInfoButton(_: Any) {
        coordinator?.halfWayHoorayDidFinish()
    }
}

// MARK: - appearance
extension HalfWayHoorayViewController {
    func setupAppearance() {
        self.navigationController?.navigationBar.isHidden = true
        setupAddInfoButton()
        setupLabels()
    }

    func setupAddInfoButton() {
        let addInfoText = NSLocalizedString("Add info", comment: "")
        addInfoButton.setTitle(addInfoText, for: .normal)
        Skinner().apply(buttonSkin: skin?.primaryButtonSkin, to: addInfoButton)
    }

    func setupLabels() {
        let receivedLabelText = NSLocalizedString("Thanks, we've received your application for work experience at ", comment: "")

        let formattedString = NSMutableAttributedString()
        formattedString.append(NSAttributedString(string: receivedLabelText, attributes: [NSAttributedString.Key.font: UIFont.f4sSystemFont(size: Style.largeTextSize, weight: UIFont.Weight.regular), NSAttributedString.Key.foregroundColor: UIColor(netHex: Colors.black)]))
        if let currentCompanyName = companyViewData?.companyName {
            formattedString.append(NSAttributedString(string: currentCompanyName, attributes: [NSAttributedString.Key.font: UIFont.f4sSystemFont(size: Style.largeTextSize, weight: UIFont.Weight.semibold), NSAttributedString.Key.foregroundColor: UIColor(netHex: Colors.black)]))
        }
        self.receivedLabel.attributedText = formattedString

        self.receivedLabel.numberOfLines = 0
        self.receivedLabel.sizeToFit()
        self.receivedLabel.textAlignment = .center

        let extraInformationText = NSLocalizedString("To complete your application we need a couple more bits of information", comment: "")
        self.extraInformationLabel.attributedText = NSAttributedString(string: extraInformationText, attributes: [NSAttributedString.Key.font: UIFont.f4sSystemFont(size: Style.largeTextSize, weight: UIFont.Weight.regular), NSAttributedString.Key.foregroundColor: UIColor(netHex: Colors.black)])

        self.extraInformationLabel.numberOfLines = 0
        self.extraInformationLabel.sizeToFit()
        self.receivedLabel.textAlignment = .center
    }
}
