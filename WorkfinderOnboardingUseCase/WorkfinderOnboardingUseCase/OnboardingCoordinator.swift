
import UIKit
import WorkfinderCommon
import WorkfinderUI
import WorkfinderCoordinators
import WorkfinderRegisterCandidate

let __bundle = Bundle(identifier: "com.workfinder.WorkfinderOnboardingUseCase")

public class OnboardingCoordinator : CoreInjectionNavigationCoordinator, OnboardingCoordinatorProtocol {
    
    weak public var delegate: OnboardingCoordinatorDelegate?
    weak var onboardingViewController: OnboardingViewController?
    
    public var onboardingDidFinish: ((OnboardingCoordinatorProtocol) -> Void)?
    
    lazy public var isOnboardingRequired: Bool = {
        (localStore.value(key: .isOnboardingRequired) as? Bool) ?? true
    }()
    
    let log: F4SAnalytics
    
    let localStore: LocalStorageProtocol

    public init(parent: Coordinating?,
                navigationRouter: NavigationRoutingProtocol,
                localStore: LocalStorageProtocol,
                log: F4SAnalytics,
                inject: CoreInjectionProtocol) {
        self.localStore = localStore
        self.log = log
        super.init(parent: parent, navigationRouter: navigationRouter, inject: inject)
    }
    
    public override func start() {
        guard isOnboardingRequired else {
            self.onboardingDidFinish?(self)
            return
        }
        log.track(.onboarding_start)
        let onboardingViewController = UIStoryboard(name: "Onboarding", bundle: __bundle).instantiateViewController(withIdentifier: "OnboardingViewController") as! OnboardingViewController
        self.onboardingViewController = onboardingViewController
        onboardingViewController.hideOnboardingControls = !isOnboardingRequired
        onboardingViewController.coordinator = self
        onboardingViewController.isLoggedIn = injected.userRepository.loadUser().candidateUuid != nil
        onboardingViewController.modalPresentationStyle = .fullScreen
        onboardingViewController.coordinator = self
        navigationRouter.present(onboardingViewController, animated: false, completion: nil)
    }
    
    func loginButtonTapped(viewController: UIViewController) {
        log.track(.onboarding_tap_sign_in)
        let loginHandler = LoginHandler(
            parentCoordinator: self,
            navigationRouter: navigationRouter,
            mainWindow: UIApplication.shared.windows.first,
            coreInjection: injected)
        loginHandler.startLoginWorkflow(screenOrder: .loginThenRegister) { [weak self] (isLoggedIn) in
            guard let self = self else { return }
            self.onboardingViewController?.isLoggedIn = isLoggedIn
            if isLoggedIn {
                self.finishOnboarding()
            }
        }
    }
    
    func justGetStartedButtonTapped(viewController: UIViewController) {
        log.track(.onboarding_tap_just_get_started)
        finishOnboarding()
    }
    
    func finishOnboarding() {
        LocalStore().setValue(false, for: LocalStore.Key.isOnboardingRequired)
        self.log.track(.onboarding_convert)
        self.onboardingDidFinish?(self)
    }
    
}
