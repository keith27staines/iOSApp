
import Foundation
import WorkfinderCommon
import WorkfinderServices
import WorkfinderCoordinators
import WorkfinderUI

protocol RegisterAndSignInCoordinatorProtocol {
    func switchMode(_ mode: RegisterAndSignInMode)
    func onUserRegisteredAndCandidateCreated(pop: Bool)
    func onRegisterAndSignInCancelled()
}

public protocol RegisterAndSignInCoordinatorParent: Coordinating {
    func onCandidateIsSignedIn()
    func onRegisterAndSignInCancelled()
}

public class RegisterAndSignInCoordinator: CoreInjectionNavigationCoordinator, RegisterAndSignInCoordinatorProtocol {
    let hideBackButton: Bool
    var firstViewController:UIViewController?
    
    public init(parent: RegisterAndSignInCoordinatorParent?,
                navigationRouter: NavigationRoutingProtocol,
                inject: CoreInjectionProtocol,
                hideBackButton: Bool) {
        self.hideBackButton = hideBackButton
        super.init(parent: parent, navigationRouter: navigationRouter, inject: inject)
    }
    
    public override func start() {
        injected.log.track(TrackingEvent(type: .uc_register_user_start))
        presentRegisterUserViewController(hideBackButton)
    }
    
    func onUserRegisteredAndCandidateCreated(pop: Bool = true) {
        injected.log.track(TrackingEvent(type: .uc_register_user_convert))
        injected.log.updateIdentity()
        if let previous = firstViewController?.previousViewController {
            // for pushed vcs
            navigationRouter.popToViewController(previous, animated: true)
        } else {
            // for presented vcs
            firstViewController?.dismiss(animated: true, completion: nil)
        }
        (parentCoordinator as? RegisterAndSignInCoordinatorParent)?.onCandidateIsSignedIn()
        parentCoordinator?.childCoordinatorDidFinish(self)
    }
    
    func onRegisterAndSignInCancelled() {
        injected.log.track(TrackingEvent(type: .uc_register_user_cancel))
        (parentCoordinator as? RegisterAndSignInCoordinatorParent)?.onRegisterAndSignInCancelled()
        parentCoordinator?.childCoordinatorDidFinish(self)
    }
    
    func switchMode(_ mode: RegisterAndSignInMode) {
        switch mode {
        case .register:
            navigationRouter.pop(animated: true)
            break
        case .signIn:
            presentSignInUserViewController()
        }
    }
    
    func presentRegisterUserViewController(_ hideBackButton: Bool) {
        let userRepository = injected.userRepository
        let candidate = userRepository.loadCandidate()
        guard candidate.uuid == nil else {
            onUserRegisteredAndCandidateCreated(pop: false)
            return
        }
        let registerUserLogic = RegisterUserLogic(
            networkConfig: injected.networkConfig,
            userRepository: userRepository,
            mode: .register,
            log: injected.log)
        
        let presenter = RegisterUserPresenter(
            coordinator: self,
            userRepository: userRepository,
            registerUserLogic: registerUserLogic)
        
        let vc = RegisterUserViewController(presenter: presenter, hidesBackButton: hideBackButton)
        firstViewController = vc
        navigationRouter.push(viewController: vc, animated: true)
    }
    
    func presentSignInUserViewController() {
        let userRepository = injected.userRepository
        let registerUserLogic = RegisterUserLogic(
            networkConfig: injected.networkConfig,
            userRepository: userRepository,
            mode: .signIn,
            log: injected.log)
        
        let presenter = SignInUserPresenter(
            coordinator: self,
            userRepository: userRepository,
            registerUserLogic: registerUserLogic)
        
        let vc = SignInViewController(presenter: presenter)
        navigationRouter.push(viewController: vc, animated: true)
    }
}
