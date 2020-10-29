
import Foundation
import WorkfinderCommon
import WorkfinderServices
import WorkfinderCoordinators
import WorkfinderUI

protocol RegisterAndSignInCoordinatorProtocol {
    func switchMode(_ mode: RegisterAndSignInMode)
    func onUserRegisteredAndCandidateCreated(pop: Bool)
    func onRegisterAndSignInCancelled()
    func startRegisterFirst()
    func startLoginFirst()
}

public protocol RegisterAndSignInCoordinatorParent: Coordinating {
    func onCandidateIsSignedIn()
    func onRegisterAndSignInCancelled()
}

public class RegisterAndSignInCoordinator: CoreInjectionNavigationCoordinator, RegisterAndSignInCoordinatorProtocol {
    let firstScreenHidesBackButton: Bool
    var firstViewController:UIViewController?
    var screenOrder: SignInScreenOrder = .registerThenLogin

    public init(parent: RegisterAndSignInCoordinatorParent?,
                navigationRouter: NavigationRoutingProtocol,
                inject: CoreInjectionProtocol,
                firstScreenHidesBackButton: Bool) {
        self.firstScreenHidesBackButton = firstScreenHidesBackButton
        super.init(parent: parent, navigationRouter: navigationRouter, inject: inject)
    }
    
    public override func start() {
        startRegisterFirst()
    }
    
    public func startLoginFirst() {
        injected.log.track(TrackingEvent(type: .uc_register_user_start))
        screenOrder = .loginThenRegister
        presentSignInUserViewController()
    }
    
    func startRegisterFirst() {
        injected.log.track(TrackingEvent(type: .uc_register_user_start))
        screenOrder = .registerThenLogin
        presentRegisterUserViewController()
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
            switch screenOrder {
            case .loginThenRegister:
                presentRegisterUserViewController()
            case .registerThenLogin:
                navigationRouter.pop(animated: true)
            }
        case .signIn:
            switch screenOrder {
            case .loginThenRegister:
                navigationRouter.pop(animated: true)
            case .registerThenLogin:
                presentSignInUserViewController()
                
            }
        }
    }
    
    func presentRegisterUserViewController() {
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
        let hideBackButton = screenOrder == .registerThenLogin && firstScreenHidesBackButton
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
        let hideBackButton = screenOrder == .loginThenRegister && firstScreenHidesBackButton
        let vc = SignInViewController(presenter: presenter, hidesBackButton: hideBackButton)
        navigationRouter.push(viewController: vc, animated: true)
    }
}
