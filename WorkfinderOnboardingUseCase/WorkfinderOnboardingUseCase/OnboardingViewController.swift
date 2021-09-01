
import UIKit
import WorkfinderCommon
import WorkfinderUI

class OnboardingViewController: UIViewController {
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var signinButton: UIButton!
    @IBOutlet weak var justGetStartedButton: UIButton!
    
    weak var coordinator: OnboardingCoordinator?

    var hideOnboardingControls: Bool = true {
        didSet {
            _ = view
            onboardingControls.forEach { $0.isHidden = hideOnboardingControls }
        }
    }
    
    var isLoggedIn: Bool = false {
        didSet { signinButton.isHidden = isLoggedIn }
    }
    
    var onboardingControls: [UIView] {
        [signinButton, justGetStartedButton]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        onboardingControls.forEach { $0.isHidden = true }
    }
    
    var viewsToFadeIn: [UIView] {
        var views = onboardingControls
        views.append(descriptionLabel)
        return views
    }
    
    func fadeInViews() {
        viewsToFadeIn.forEach { $0.alpha = 0 }
        UIView.animate(withDuration: 0.5) {
            self.viewsToFadeIn.forEach { $0.alpha = 1 }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        adjustNavigationBar()
        setupAppearance()
        print(descriptionLabel.frame)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        descriptionLabel.isHidden = false
        descriptionLabel.alpha = 0
        signinButton.alpha = 0
        justGetStartedButton.alpha = 0
        fadeInViews()
    }
}

extension OnboardingViewController {
    func adjustNavigationBar() {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    func setUpButtons() {
        justGetStartedButton.isHidden = hideOnboardingControls
        signinButton.isHidden = hideOnboardingControls
        justGetStartedButton.layer.cornerRadius = 8
        signinButton.layer.cornerRadius = 8
        justGetStartedButton.layer.masksToBounds = true
        signinButton.layer.masksToBounds = true
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
    @IBAction func signinOrRegisterButtonTapped(_: AnyObject) {
        coordinator?.loginButtonTapped(viewController: self)
    }

    @IBAction func justgetStartedButtonTapped(_: AnyObject) {
        signinButton.isEnabled = false
        justGetStartedButton.isEnabled = false
        coordinator?.justGetStartedButtonTapped(viewController: self)
    }
    
}
