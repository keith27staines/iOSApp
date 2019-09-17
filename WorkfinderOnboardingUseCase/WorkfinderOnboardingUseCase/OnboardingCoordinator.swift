
import UIKit
import WorkfinderCommon
import WorkfinderCoordinators

public protocol OnboardingCoordinatorProtocol : Coordinating {
    var hideOnboardingControls: Bool { get set }
    var delegate: OnboardingCoordinatorDelegate? { get set }
    var onboardingDidFinish: ((OnboardingCoordinatorProtocol) -> Void)? { get set }
}

public protocol OnboardingCoordinatorDelegate : class {
    func shouldEnableLocation(_ :Bool)
}

let __bundle = Bundle(identifier: "com.f4s.WorkfinderOnboardingUseCase")

public class OnboardingCoordinator : NavigationCoordinator, OnboardingCoordinatorProtocol {
    
    weak public var delegate: OnboardingCoordinatorDelegate?
    weak var onboardingViewController: OnboardingViewController?
    weak var partnerSelectionViewController: PartnerSelectionViewController?
    
    public var onboardingDidFinish: ((OnboardingCoordinatorProtocol) -> Void)?
    public let partnerService: F4SPartnerServiceProtocol
    
    public var hideOnboardingControls: Bool = true {
        didSet {
            onboardingViewController?.hideOnboardingControls = hideOnboardingControls
        }
    }

    public init(parent: Coordinating?,
                navigationRouter: NavigationRoutingProtocol,
                partnerService: F4SPartnerServiceProtocol) {
        self.partnerService = partnerService
        super.init(parent: parent, navigationRouter: navigationRouter)
    }
    
    public override func start() {
        let onboardingViewController = UIStoryboard(name: "Onboarding", bundle: __bundle).instantiateViewController(withIdentifier: "OnboardingViewController") as! OnboardingViewController
        self.onboardingViewController = onboardingViewController
        onboardingViewController.hideOnboardingControls = hideOnboardingControls
        onboardingViewController.shouldEnableLocation = { [weak self] enable in
            self?.delegate?.shouldEnableLocation(enable)
            self?.showPartnerList()
        }
        navigationRouter.present(onboardingViewController, animated: false, completion: nil)
    }
    
    func showPartnerList() {
        let partnersModel = F4SPartnersModel(partnerService: partnerService)
        let vc = UIStoryboard(name: "SelectPartner", bundle: __bundle).instantiateInitialViewController() as! PartnerSelectionViewController
        vc.partnersModel = partnersModel
        partnerSelectionViewController = vc
        vc.doneButtonTapped = { [weak self] in
            guard let strongSelf = self else { return }
            LocalStore().setValue(false, for: LocalStore.Key.isFirstLaunch)
            strongSelf.onboardingDidFinish?(strongSelf)
        }
        onboardingViewController?.present(vc, animated: true, completion: nil)
    }
}
