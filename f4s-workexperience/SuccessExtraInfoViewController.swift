//
//  SuccessExtraInfoViewController.swift
//  f4s-workexperience
//
//  Created by Sergiu Simon on 10/01/17.
//  Copyright © 2017 freshbyte. All rights reserved.
//

import UIKit

class SuccessExtraInfoViewController: UIViewController {

    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var timelineButton: UIButton!
    @IBOutlet weak var viewMapButton: UIButton!
    @IBOutlet weak var successLabel: UILabel!

    let backgroundPopoverView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        adjustAppearence()
    }

    override func viewWillDisappear(_ animated: Bool) {
        backgroundPopoverView.removeFromSuperview()
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// MARK: - UI Setup
extension SuccessExtraInfoViewController {

    func adjustAppearence() {
        setupButtons()
        setupLabels()
    }

    func setupLabels() {
        let infoStr = NSLocalizedString("Click Timeline to view application progress and Map to see more opportunities.", comment: "")
        let timelineStr = NSLocalizedString("Timeline", comment: "")
        let mapStr = NSLocalizedString("Map", comment: "")

        let infoAttr = [
            NSForegroundColorAttributeName: UIColor(netHex: Colors.black),
            NSFontAttributeName: UIFont.f4sSystemFont(size: Style.largeTextSize, weight: UIFontWeightRegular),
        ]
        let boldedInfoAttr = [
            NSForegroundColorAttributeName: UIColor(netHex: Colors.black),
            NSFontAttributeName: UIFont.f4sSystemFont(size: Style.largeTextSize, weight: UIFontWeightBold),
        ]

        let infoNsStr = NSString(string: infoStr)

        let timelineStrRange = infoNsStr.range(of: timelineStr)
        let mapStrRange = infoNsStr.range(of: mapStr)

        let attrStr = NSMutableAttributedString(string: infoStr, attributes: infoAttr)

        attrStr.setAttributes(boldedInfoAttr, range: timelineStrRange)
        attrStr.setAttributes(boldedInfoAttr, range: mapStrRange)

        self.infoLabel.attributedText = attrStr
    }

    func setupButtons() {
        let timelineStr = NSLocalizedString("Timeline", comment: "")
        let mapStr = NSLocalizedString("Map", comment: "")

        self.timelineButton.layer.masksToBounds = true
        self.timelineButton.layer.cornerRadius = 10
        self.timelineButton.setAttributedTitle(NSAttributedString(string: timelineStr, attributes: [NSFontAttributeName: UIFont.f4sSystemFont(size: Style.biggerMediumTextSize, weight: UIFontWeightRegular), NSForegroundColorAttributeName: UIColor(netHex: Colors.white)]), for: .normal)
        self.timelineButton.setBackgroundColor(color: UIColor(netHex: Colors.lightGreen), forUIControlState: .highlighted)
        self.timelineButton.setBackgroundColor(color: UIColor(netHex: Colors.whiteGreen), forUIControlState: .disabled)
        self.timelineButton.setBackgroundColor(color: UIColor(netHex: Colors.mediumGreen), forUIControlState: .normal)
        self.timelineButton.setTitleColor(UIColor.white, for: .normal)
        self.timelineButton.setTitleColor(UIColor.white, for: .highlighted)

        self.viewMapButton.layer.masksToBounds = true
        self.viewMapButton.layer.cornerRadius = 10
        self.viewMapButton.setAttributedTitle(NSAttributedString(string: mapStr, attributes: [NSFontAttributeName: UIFont.f4sSystemFont(size: Style.biggerMediumTextSize, weight: UIFontWeightRegular), NSForegroundColorAttributeName: UIColor(netHex: Colors.white)]), for: .normal)

        self.viewMapButton.setBackgroundColor(color: UIColor(netHex: Colors.lightGreen), forUIControlState: .highlighted)
        self.viewMapButton.setBackgroundColor(color: UIColor(netHex: Colors.whiteGreen), forUIControlState: .disabled)
        self.viewMapButton.setBackgroundColor(color: UIColor(netHex: Colors.mediumGreen), forUIControlState: .normal)
        self.viewMapButton.setTitleColor(UIColor.white, for: .normal)
        self.viewMapButton.setTitleColor(UIColor.white, for: .highlighted)

    }

    func getHeight() -> CGFloat {
        let sum = 30 + 90 + 35 + self.successLabel.bounds.height + 30 + self.infoLabel.bounds.height + 39 + self.timelineButton.bounds.height + 30 + 30
        return sum
    }
}

// MARK: - Popover Delegate
extension SuccessExtraInfoViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for _: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    func popoverPresentationControllerShouldDismissPopover(_: UIPopoverPresentationController) -> Bool {
        return false
    }
}

// MARK: - User Interaction
extension SuccessExtraInfoViewController {

    @IBAction func timelineButtonTouched(_: UIButton) {
        let presentingCtrl = self.presentingViewController
        self.navigationController?.dismiss(animated: false, completion: {
            let presentingCtrl2 = presentingCtrl?.presentingViewController
            presentingCtrl?.dismiss(animated: false, completion: {
                let presentingCtrl3 = presentingCtrl2?.presentingViewController
                presentingCtrl2?.dismiss(animated: false, completion: {
                    let presentingCtrl4 = presentingCtrl3?.presentingViewController
                    if let drawerCtrl = presentingCtrl4 as? DrawerController {
                        if let centerCtrl = drawerCtrl.centerViewController {
                            // centerCtrl is customTabBarCtrl - see setupDrawerController
                            if let tabBarCtrl = centerCtrl as? CustomTabBarViewController {
                                tabBarCtrl.selectedIndex = 0
                            }
                        }
                    }
                    presentingCtrl3?.dismiss(animated: false, completion: nil)
                })
            })
        })
    }

    @IBAction func viewMapButtonTouched(_: UIButton) {
        if let window = view.window {
            NotificationHelper.sharedInstance.updateToolbarButton(window: window)
        }
        let presentingCtrl = self.presentingViewController
        self.navigationController?.dismiss(animated: false, completion: {
            let presentingCtrl2 = presentingCtrl?.presentingViewController
            presentingCtrl?.dismiss(animated: false, completion: {
                let presentingCtrl3 = presentingCtrl2?.presentingViewController
                presentingCtrl2?.dismiss(animated: false, completion: {
                    let presentingCtrl4 = presentingCtrl3?.presentingViewController
                    if let drawerCtrl = presentingCtrl4 as? DrawerController {
                        if let centerCtrl = drawerCtrl.centerViewController {
                            // centerCtrl is customTabBarCtrl - see setupDrawerController
                            if let tabBarCtrl = centerCtrl as? CustomTabBarViewController {
                                tabBarCtrl.selectedIndex = 2
                            }
                        }
                    }
                    presentingCtrl3?.dismiss(animated: false, completion: nil)
                })
            })
        })
    }
}
