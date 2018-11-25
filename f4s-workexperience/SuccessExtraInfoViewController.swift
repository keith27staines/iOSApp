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

    @IBOutlet weak var recommendationsButton: UIButton!
    

    let backgroundPopoverView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        applyStyle()
        recommendationsButton.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        F4SUserStatusService.shared.beginStatusUpdate()
    }

    override func viewWillDisappear(_ animated: Bool) {
        backgroundPopoverView.removeFromSuperview()
        super.viewWillDisappear(animated)
    }
}

// MARK: - UI Setup
extension SuccessExtraInfoViewController {
    
    func applyStyle() {
        let skinner = Skinner()
        skinner.apply(buttonSkin: skin?.primaryButtonSkin, to: timelineButton)
        skinner.apply(buttonSkin: skin?.primaryButtonSkin, to: viewMapButton)
    }

    func getHeight() -> CGFloat {
        var sum: CGFloat = 30 + 90 + 35
        sum += self.successLabel.bounds.height
        sum += 30
        sum += self.infoLabel.bounds.height
        sum += 39
        sum += self.timelineButton.bounds.height
        sum += 30 + 30
//        let sum = 30 + 90 + 35 + self.successLabel.bounds.height + 30 + self.infoLabel.bounds.height + 39 + self.timelineButton.bounds.height + 30 + 30
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

    @IBAction func recommendationsButtonPressed(_ sender: UIButton) {
        CustomNavigationHelper.sharedInstance.rewindAndNavigateToRecommendations(from: self, show: nil)
    }
    
    @IBAction func timelineButtonTouched(_: UIButton) {
        CustomNavigationHelper.sharedInstance.rewindAndNavigateToTimeline(from: self, show: nil)
    }
    
    @IBAction func viewMapButtonTouched(_: UIButton) {
        CustomNavigationHelper.sharedInstance.rewindAndNavigateToMap(from: self)
    }
}
