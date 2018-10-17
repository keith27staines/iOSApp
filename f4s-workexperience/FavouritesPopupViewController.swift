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
        let skinner = Skinner()
        skinner.apply(buttonSkin: skin?.primaryButtonSkin, to: okButton)
        skinner.apply(buttonSkin: skin?.secondaryButtonSkin, to: cancelButton)
        okButton.setTitle(NSLocalizedString("Ok", comment: ""), for: .normal)
        cancelButton.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
    }
    
    func setupLabels() {
        let titleText = NSLocalizedString("Maximum of \(AppConstants.maximumNumberOfShortlists) favourites", comment: "")
        titleLabel.attributedText = NSAttributedString(string: titleText, attributes: [NSAttributedString.Key.font: UIFont.f4sSystemFont(size: Style.largeTextSize, weight: UIFont.Weight.semibold), NSAttributedString.Key.foregroundColor: UIColor(netHex: Colors.black)])
        
        let contentText = NSLocalizedString("Please remove a company from your favourites, in order to add a new company.", comment: "")
        contentLabel.attributedText = NSAttributedString(string: contentText, attributes: [NSAttributedString.Key.font: UIFont.f4sSystemFont(size: Style.smallerMediumTextSize, weight: UIFont.Weight.regular), NSAttributedString.Key.foregroundColor: UIColor(netHex: Colors.black)])
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
        CustomNavigationHelper.sharedInstance.navigateToFavourites()
    }
}
