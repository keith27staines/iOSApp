
import UIKit
import WorkfinderCommon
import WorkfinderCoordinators

let __bundle = Bundle(identifier: "com.workfinder.WorkfinderOnboardingUseCase")

public class OnboardingCoordinator : NavigationCoordinator, OnboardingCoordinatorProtocol {
    
    weak public var delegate: OnboardingCoordinatorDelegate?
    weak var onboardingViewController: OnboardingViewController?
    
    public var onboardingDidFinish: ((OnboardingCoordinatorProtocol) -> Void)?
    
    public var isFirstLaunch: Bool = true {
        didSet {
            onboardingViewController?.hideOnboardingControls = !isFirstLaunch
        }
    }
    
    let log: F4SAnalytics
    
    let localStore: LocalStorageProtocol

    public init(parent: Coordinating?,
                navigationRouter: NavigationRoutingProtocol,
                localStore: LocalStorageProtocol,
                log: F4SAnalytics) {
        self.localStore = localStore
        self.log = log
        super.init(parent: parent, navigationRouter: navigationRouter)
    }
    
    public override func start() {
        guard isFirstLaunch else {
            self.onboardingDidFinish?(self)
            return
        }
        log.track(TrackingEvent(type: .uc_onboarding_start))
        let onboardingViewController = UIStoryboard(name: "Onboarding", bundle: __bundle).instantiateViewController(withIdentifier: "OnboardingViewController") as! OnboardingViewController
        self.onboardingViewController = onboardingViewController
        onboardingViewController.hideOnboardingControls = !isFirstLaunch
        onboardingViewController.shouldEnableLocation = { [weak self] enable in
            guard let self = self else { return }
            self.delegate?.shouldEnableLocation(enable)
            LocalStore().setValue(false, for: LocalStore.Key.isFirstLaunch)
            self.log.track(TrackingEvent(type: .uc_onboarding_convert))
            self.onboardingDidFinish?(self)
        }
        onboardingViewController.modalPresentationStyle = .fullScreen
        navigationRouter.present(onboardingViewController, animated: false, completion: nil)
    }
    
}
