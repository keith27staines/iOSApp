import UIKit
import Reachability
import WorkfinderCommon
import WorkfinderServices
import WorkfinderUI

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

    var placementService: F4SPlacementServiceProtocol!
}
