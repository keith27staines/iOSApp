//
//  RatePlacementViewController.swift
//  f4s-workexperience
//
//  Created by Sergiu Simon on 06/01/17.
//  Copyright © 2017 freshbyte. All rights reserved.
//

import UIKit
import Reachability

protocol RatingControlDelegate {
    func didUpdateRatingValue(ratingControll: RatingControl, rating: Int)
}

class RatePlacementViewController: UIViewController {

    @IBOutlet weak var ratingControlStackView: RatingControl!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var questionLabel: UILabel!

    @IBOutlet weak var questionImageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var questionLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var ratinControlStackViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var submitButtonTopConstraint: NSLayoutConstraint!

    var placementUuid: String?
    var company: Company?
    let backgroundPopoverView = UIView()
    weak var ratePlacementProtocol: RatePlacementProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        ratingControlStackView.delegate = self
    }
    
    lazy var placementService: F4SPlacementServiceProtocol = {
        return F4SPlacementService()
    }()
}

// MARK: - UI Setup
extension RatePlacementViewController {

    func setupAppearance() {
        setupButtons()
        getCompany()
    }

    func setupButtons() {
        Skinner().apply(buttonSkin: skin?.primaryButtonSkin, to: submitButton)
        self.submitButton.setTitle(NSLocalizedString("Submit", comment: ""), for: .normal)        
    }

    func setupLabels() {
        let questionStr = NSLocalizedString("How was your work experience at ?", comment: "")

        let questionAttrStr = NSMutableAttributedString(
            string: questionStr,
            attributes: [NSAttributedStringKey.font: UIFont.f4sSystemFont(size: Style.largeTextSize, weight: UIFont.Weight.regular), NSAttributedStringKey.foregroundColor: UIColor.black,])
        if let companyName = self.company?.name {
            let companyNameAttrStr = NSMutableAttributedString(
                string: companyName,
                attributes: [NSAttributedStringKey.font: UIFont.f4sSystemFont(size: Style.largeTextSize,weight: UIFont.Weight.semibold),NSAttributedStringKey.foregroundColor: UIColor.black])
            questionAttrStr.insert(companyNameAttrStr, at: questionStr.count - 1)
        }
        self.questionLabel.attributedText = questionAttrStr
    }

    func getHeight() -> CGFloat {
        var sum = questionImageViewTopConstraint.constant
        sum += questionLabelTopConstraint.constant
        sum += ratinControlStackViewTopConstraint.constant
        sum += submitButtonTopConstraint.constant
        sum += submitButton.frame.size.height
        sum += questionLabel.frame.size.height
        sum += ratingControlStackView.frame.size.height
        sum += 140
        return sum
    }

    func getCompany() {
        guard let placementUuid = self.placementUuid,
            let placement = PlacementDBOperations.sharedInstance.getPlacementWithUuid(placementUuid: placementUuid) else {
            self.company = nil
            log.debug("Can't get company")
            return
        }

        DatabaseOperations.sharedInstance.getCompanies(withUuid: [placement.companyUuid!], completed: {
            companies in
            self.company = companies.first
            self.setupLabels()
        })
    }
}

// MARK: UIPopoverPresentationControllerDelegate
extension RatePlacementViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for _: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    func popoverPresentationControllerShouldDismissPopover(_: UIPopoverPresentationController) -> Bool {
        return false
    }
}

// MARK: RatingControlDelegate
extension RatePlacementViewController: RatingControlDelegate {

    func didUpdateRatingValue(ratingControll _: RatingControl, rating: Int) {
        if rating > 0 {
            self.submitButton.isEnabled = true
        } else {
            self.submitButton.isEnabled = false
        }
    }
}

// MARK: - User Interaction
extension RatePlacementViewController {

    @IBAction func submitButtonTouched(_: UIButton) {

        if let reachability = Reachability() {
            if !reachability.isReachableByAnyMeans {
                MessageHandler.sharedInstance.display("No Internet Connection.", parentCtrl: self)
                log.debug("No internet connection")
                return
            }
        }

        guard let placementUuid = self.placementUuid else {
            log.debug("Placement uuid is empty")
            return
        }

        MessageHandler.sharedInstance.showLoadingOverlay(self.view)
        let rating = self.ratingControlStackView.rating
        placementService.ratePlacement(placementUuid: placementUuid, rating: rating) { [weak self] (result) in
            guard let strongSelf = self else { return }
            switch result {
            case .error(let error):
                log.error(error)
            case .success(_):
                log.debug("rating of \(rating) submited for placement \(placementUuid)")
            }
            MessageHandler.sharedInstance.hideLoadingOverlay()
            strongSelf.backgroundPopoverView.removeFromSuperview()
            strongSelf.dismiss(animated: true, completion: {
                strongSelf.ratePlacementProtocol?.dismissRateController()
            })
        }
    }
}
