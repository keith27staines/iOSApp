
import UIKit
import WorkfinderCommon
import WorkfinderUI

public class SuccessExtraInfoViewController: UIViewController {

    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var timelineButton: UIButton!
    @IBOutlet weak var viewMapButton: UIButton!
    @IBOutlet weak var successLabel: UILabel!

    @IBOutlet weak var centerView: UIView!
    
    weak var log: F4SAnalyticsAndDebugging?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        centerView.backgroundColor = UIColor.white
        centerView.layer.cornerRadius = 8
        centerView.layer.masksToBounds = true
        applyStyle()
    }
    
    public var timelineButtonWasTapped: (() -> Void)?
    public var searchButtonWasTapped: (() -> Void)?
}

// MARK: - UI Setup
extension SuccessExtraInfoViewController {
    
    func applyStyle() {
        let skinner = Skinner()
        skinner.apply(buttonSkin: skin?.primaryButtonSkin, to: timelineButton)
        skinner.apply(buttonSkin: skin?.primaryButtonSkin, to: viewMapButton)
    }
}

// MARK: - User Interaction
extension SuccessExtraInfoViewController {
    
    @IBAction func timelineButtonTouched(_: UIButton) {
        log?.track(event: .applyHoorayMessagesTap, properties: nil)
        timelineButtonWasTapped?()
    }
    
    @IBAction func viewMapButtonTouched(_: UIButton) {
        log?.track(event: .applyHooraySearchTap, properties: nil)
        searchButtonWasTapped?()
    }
}
