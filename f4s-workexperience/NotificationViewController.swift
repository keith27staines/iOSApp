//
//  NotificationViewController.swift
//  f4s-workexperience
//
//  Created by Alex Astilean on 29/11/2016.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import UIKit

class NotificationViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!

    @IBOutlet weak var titleTopContraint: NSLayoutConstraint!
    @IBOutlet weak var contentTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonsTopConstraint: NSLayoutConstraint!

    fileprivate let lineHeight: CGFloat = 25
    var flag = true
    var currentCompany: Company?
    let backgroundPopoverView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setNotificationFlag()
        setupView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// MARK: UIPopoverPresentationControllerDelegate
extension NotificationViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for _: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    func popoverPresentationControllerShouldDismissPopover(_: UIPopoverPresentationController) -> Bool {
        backgroundPopoverView.removeFromSuperview()
        return true
    }
}

// MARK: - appearance
extension NotificationViewController {

    func setNotificationFlag() {
        guard let didDeclineRemoteNotifications = UserDefaults.standard.value(forKey: UserDefaultsKeys.didDeclineRemoteNotifications) else {
            return
        }
        if let didDeclineRemoteNotificationsBool = didDeclineRemoteNotifications as? Bool {
            self.flag = !didDeclineRemoteNotificationsBool
        }
    }

    func setupView() {
        var rightButtonText = ""
        var leftButtonText = ""
        var titleText = ""
        var contentText = ""
        if flag {
            rightButtonText = NSLocalizedString("Enable", comment: "")
            leftButtonText = NSLocalizedString("Skip", comment: "")
            titleText = NSLocalizedString("Notifications", comment: "")
            contentText = NSLocalizedString("In order for us to update you on progress and contact employers on your behalf, you need to enable notifications. \n \nYou only have to do this once!", comment: "")
        } else {
            rightButtonText = NSLocalizedString("Settings", comment: "")
            leftButtonText = NSLocalizedString("Skip", comment: "")
            titleText = NSLocalizedString("Notifications", comment: "")
            contentText = NSLocalizedString("In order for us to update you on progress and contact employers on your behalf, you need to go to settings to enable notifications for the Workfinder app.", comment: "")
        }
        setupButtons(leftButtonText: leftButtonText, rightButtonText: rightButtonText)
        setupLabels(titleText: titleText, contentText: contentText)
    }

    func getHeight() -> CGFloat {
        let sum = titleTopContraint.constant + contentTopConstraint.constant + buttonsTopConstraint.constant + titleTopContraint.constant + leftButton.frame.size.height + titleLabel.frame.size.height
        return sum
    }

    func registerForPushNotifications() {
        let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        UIApplication.shared.registerUserNotificationSettings(settings)
    }

    func setupButtons(leftButtonText: String, rightButtonText: String) {
        rightButton.backgroundColor = UIColor(netHex: Colors.mediumGreen)
        rightButton.layer.cornerRadius = 10
        rightButton.layer.masksToBounds = true
        rightButton.setAttributedTitle(NSAttributedString(string: rightButtonText, attributes: [NSAttributedStringKey.font: UIFont.f4sSystemFont(size: Style.biggerMediumTextSize, weight: UIFont.Weight.regular), NSAttributedStringKey.foregroundColor: UIColor(netHex: Colors.white)]), for: .normal)
        
        rightButton.setBackgroundColor(color: UIColor(netHex: Colors.mediumGreen), forUIControlState: .normal)
        rightButton.setBackgroundColor(color: UIColor(netHex: Colors.lightGreen), forUIControlState: .highlighted)
        rightButton.setTitleColor(UIColor.white, for: .normal)
        rightButton.setTitleColor(UIColor.white, for: .highlighted)

        leftButton.layer.cornerRadius = 10
        leftButton.layer.borderColor = UIColor(netHex: Colors.mediumGreen).cgColor
        leftButton.layer.borderWidth = 0.5
        leftButton.setAttributedTitle(NSAttributedString(string: leftButtonText, attributes: [NSAttributedStringKey.font: UIFont.f4sSystemFont(size: Style.biggerMediumTextSize, weight: UIFont.Weight.regular), NSAttributedStringKey.foregroundColor: UIColor(netHex: Colors.black)]), for: .normal)
    }

    func setupLabels(titleText: String, contentText: String) {
        titleLabel.attributedText = NSAttributedString(string: titleText, attributes: [NSAttributedStringKey.font: UIFont.f4sSystemFont(size: Style.largeTextSize, weight: UIFont.Weight.semibold), NSAttributedStringKey.foregroundColor: UIColor(netHex: Colors.black)])

        let font = UIFont.f4sSystemFont(size: Style.smallerMediumTextSize, weight: UIFont.Weight.regular)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineHeight - font.lineHeight

        contentLabel.attributedText = NSAttributedString(string: contentText, attributes: [NSAttributedStringKey.font: font, NSAttributedStringKey.foregroundColor: UIColor(netHex: Colors.black), NSAttributedStringKey.paragraphStyle: paragraphStyle])
        contentLabel.frame.size.width = self.view.frame.size.width - 100

        contentLabel.numberOfLines = 0
        contentLabel.sizeToFit()
    }
}

// MARK: - user interraction
extension NotificationViewController {
    @IBAction func leftButton(_: Any) {
        self.backgroundPopoverView.removeFromSuperview()
        self.dismiss(animated: true, completion: nil)
        guard let viewCtrl = self.presentingViewController,
            let company = self.currentCompany else {
            log.error("Can't present cover letter")
            return
        }
        
        CustomNavigationHelper.sharedInstance.presentCoverLetterController(parentCtrl: viewCtrl, currentCompany: company)
    }

    @IBAction func rightButton(_: Any) {
        self.backgroundPopoverView.removeFromSuperview()
        if !flag {
            if let url = URL(string: UIApplicationOpenSettingsURLString), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.openURL(url)
            }
            self.dismiss(animated: true, completion: nil)

            guard let viewCtrl = self.presentingViewController,
                let company = self.currentCompany else {
                log.error("Can't present cover letter")
                return
            }
            CustomNavigationHelper.sharedInstance.presentCoverLetterController(parentCtrl: viewCtrl, currentCompany: company)
        } else {
            registerForPushNotifications()
            self.dismiss(animated: true, completion: nil)
        }
    }
}
