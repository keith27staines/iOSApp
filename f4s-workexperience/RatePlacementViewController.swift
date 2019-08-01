import UIKit
import Reachability
import WorkfinderCommon
import WorkfinderServices

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
            attributes: [NSAttributedString.Key.font: UIFont.f4sSystemFont(size: Style.largeTextSize, weight: UIFont.Weight.regular), NSAttributedString.Key.foregroundColor: UIColor.black,])
        if let companyName = self.company?.name {
            let companyNameAttrStr = NSMutableAttributedString(
                string: companyName,
                attributes: [NSAttributedString.Key.font: UIFont.f4sSystemFont(size: Style.largeTextSize,weight: UIFont.Weight.semibold),NSAttributedString.Key.foregroundColor: UIColor.black])
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
                sharedUserMessageHandler.displayAlertFor("No Internet Connection.", parentCtrl: self)
                return
            }
        }

        guard let placementUuid = self.placementUuid else { return }

        sharedUserMessageHandler.showLoadingOverlay(self.view)
        let rating = self.ratingControlStackView.rating
        placementService.ratePlacement(placementUuid: placementUuid, rating: rating) { [weak self] (result) in
            guard let strongSelf = self else { return }
            switch result {
            case .error(let error):
                globalLog.error(error)
            case .success(_):
                break
            }
            sharedUserMessageHandler.hideLoadingOverlay()
            strongSelf.backgroundPopoverView.removeFromSuperview()
            strongSelf.dismiss(animated: true, completion: {
                strongSelf.ratePlacementProtocol?.dismissRateController()
            })
        }
    }
}
