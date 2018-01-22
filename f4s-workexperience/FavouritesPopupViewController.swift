//
//  FavouritesPopupViewController.swift
//  f4s-workexperience
//
//  Created by Timea Tivadar on 2/9/17.
//  Copyright © 2017 freshbyte. All rights reserved.
//

import Foundation
import UIKit

class FavouritesPopupViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var okButton: UIButton!
    
    @IBOutlet weak var titleTopContraint: NSLayoutConstraint!
    @IBOutlet weak var contentTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonsTopConstraint: NSLayoutConstraint!
    
    fileprivate let lineHeight: CGFloat = 25
    let backgroundPopoverView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtons()
        setupLabels()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// MARK: UIPopoverPresentationControllerDelegate
extension FavouritesPopupViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for _: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func popoverPresentationControllerShouldDismissPopover(_: UIPopoverPresentationController) -> Bool {
        backgroundPopoverView.removeFromSuperview()
        return true
    }
}

// MARK: - appearance
extension FavouritesPopupViewController {
    
    func getHeight() -> CGFloat {
        let sum = titleTopContraint.constant + contentTopConstraint.constant + buttonsTopConstraint.constant + contentLabel.frame.size.height + cancelButton.frame.size.height + titleLabel.frame.size.height
        return sum
    }
    
    func setupButtons() {
        okButton.layer.masksToBounds = true
        okButton.layer.cornerRadius = 10
        okButton.setAttributedTitle(NSAttributedString(string: NSLocalizedString("Ok", comment: ""), attributes: [NSAttributedStringKey.font: UIFont.f4sSystemFont(size: Style.biggerMediumTextSize, weight: UIFont.Weight.regular), NSAttributedStringKey.foregroundColor: UIColor(netHex: Colors.white)]), for: .normal)
        okButton.setBackgroundColor(color: UIColor(netHex: Colors.lightGreen), forUIControlState: .highlighted)
        okButton.setBackgroundColor(color: UIColor(netHex: Colors.mediumGreen), forUIControlState: .normal)
        okButton.setTitleColor(UIColor.white, for: .normal)
        okButton.setTitleColor(UIColor.white, for: .highlighted)
        
        cancelButton.layer.cornerRadius = 10
        cancelButton.layer.borderColor = UIColor(netHex: Colors.mediumGreen).cgColor
        cancelButton.layer.borderWidth = 0.5
        cancelButton.setAttributedTitle(NSAttributedString(string: NSLocalizedString("Cancel", comment: ""), attributes: [NSAttributedStringKey.font: UIFont.f4sSystemFont(size: Style.biggerMediumTextSize, weight: UIFont.Weight.regular), NSAttributedStringKey.foregroundColor: UIColor(netHex: Colors.black)]), for: .normal)
    }
    
    func setupLabels() {
        let titleText = NSLocalizedString("Maximum of \(AppConstants.maximumNumberOfShortlists) favourites", comment: "")
        titleLabel.attributedText = NSAttributedString(string: titleText, attributes: [NSAttributedStringKey.font: UIFont.f4sSystemFont(size: Style.largeTextSize, weight: UIFont.Weight.semibold), NSAttributedStringKey.foregroundColor: UIColor(netHex: Colors.black)])
        
        let contentText = NSLocalizedString("Please remove a company from your favourites, in order to add a new company.", comment: "")
        contentLabel.attributedText = NSAttributedString(string: contentText, attributes: [NSAttributedStringKey.font: UIFont.f4sSystemFont(size: Style.smallerMediumTextSize, weight: UIFont.Weight.regular), NSAttributedStringKey.foregroundColor: UIColor(netHex: Colors.black)])
        contentLabel.sizeToFit()
    }
}

// MARK: - user interraction
extension FavouritesPopupViewController {
    @IBAction func cancelButtonTouched(_ sender: Any) {
        self.backgroundPopoverView.removeFromSuperview()
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func okButtonTouched(_ sender: Any) {
        self.backgroundPopoverView.removeFromSuperview()
        
        if let window = self.view.window {
            CustomNavigationHelper.sharedInstance.createTabBarControllersAndMoveToFavourites(window: window)
        }
    }
}
