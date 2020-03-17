
import UIKit
import WorkfinderCommon
import WorkfinderCoordinators

let __bundle = Bundle(identifier: "com.f4s.WorkfinderOnboardingUseCase")

public class OnboardingCoordinator : NavigationCoordinator, OnboardingCoordinatorProtocol {
    
    weak public var delegate: OnboardingCoordinatorDelegate?
    weak var onboardingViewController: OnboardingViewController?
    
    public var onboardingDidFinish: ((OnboardingCoordinatorProtocol) -> Void)?
    
    public var hideOnboardingControls: Bool = true {
        didSet {
            onboardingViewController?.hideOnboardingControls = hideOnboardingControls
        }
    }
    
    let localStore: LocalStorageProtocol

    public init(parent: Coordinating?,
                navigationRouter: NavigationRoutingProtocol,
                localStore: LocalStorageProtocol) {
        self.localStore = localStore
        super.init(parent: parent, navigationRouter: navigationRouter)
    }
    
    public override func start() {
        let onboardingViewController = UIStoryboard(name: "Onboarding", bundle: __bundle).instantiateViewController(withIdentifier: "OnboardingViewController") as! OnboardingViewController
        self.onboardingViewController = onboardingViewController
        onboardingViewController.hideOnboardingControls = hideOnboardingControls
        onboardingViewController.shouldEnableLocation = { [weak self] enable in
            guard let self = self else { return }
            self.delegate?.shouldEnableLocation(enable)
            LocalStore().setValue(false, for: LocalStore.Key.isFirstLaunch)
            self.onboardingDidFinish?(self)
        }
        navigationRouter.present(onboardingViewController, animated: false, completion: nil)
    }
    
}
