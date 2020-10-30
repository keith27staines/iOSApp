
import UIKit
import WorkfinderCommon
import WorkfinderUI

class OnboardingViewController: UIViewController {
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var enterLocationButton: UIButton!
    @IBOutlet weak var enableLocationButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginLabel: UILabel!
    
    weak var coordinator: OnboardingCoordinator?
    var shouldEnableLocation: ((Bool) -> Void)?
    var hideOnboardingControls: Bool = true {
        didSet {
            _ = view
            viewsToFadeIn.forEach { $0.isHidden = hideOnboardingControls }
        }
    }
    
    var isLoggedIn: Bool = false {
        didSet {
            if isLoggedIn {
                self.loginLabel.isHidden = true
                self.loginButton.isHidden = true
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewsToFadeIn.forEach { $0.isHidden = true }
    }
    
    lazy var viewsToFadeIn: [UIView] = [
        enterLocationButton,
        enableLocationButton,
        loginLabel,
        loginButton
    ]
    
    func fadeInViews() {
        viewsToFadeIn.forEach { $0.alpha = 0 }
        UIView.animate(withDuration: 0.5) {
            self.viewsToFadeIn.forEach { $0.alpha = 1 }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        adjustNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupAppearance()
        fadeInViews()
    }
}

extension OnboardingViewController {
    func adjustNavigationBar() {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    func setUpButtons() {
        enableLocationButton.isHidden = hideOnboardingControls
        enterLocationButton.isHidden = hideOnboardingControls
        enableLocationButton.layer.cornerRadius = 12
        enterLocationButton.layer.cornerRadius = 12
        enableLocationButton.layer.masksToBounds = true
        enterLocationButton.layer.masksToBounds = true
    }

    func setupAppearance() {
        styleNavigationController()
        setUpButtons()
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
}

extension OnboardingViewController {
    @IBAction func enterLocationButtonTapped(_: AnyObject) {
        enterLocationButton.isEnabled = false
        shouldEnableLocation?(false)
    }

    @IBAction func enableLocationButtonTapped(_: AnyObject) {
        enterLocationButton.isEnabled = false
        shouldEnableLocation?(true)
    }
    
    @IBAction func loginTapped(_:AnyObject) {
        coordinator?.loginButtonTapped(viewController: self)
    }
    
}
