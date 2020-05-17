
import Foundation
import WorkfinderCommon
import WorkfinderServices
import WorkfinderCoordinators

protocol RegisterAndSignInCoordinatorProtocol {
    func switchMode(_ mode: RegisterAndSignInMode)
    func onUserRegisteredAndCandidateCreated(pop: Bool)
}

protocol RegisterAndSignInCoordinatorParent: Coordinating {
    func onCandidateIsSignedIn()
}

class RegisterAndSignInCoordinator: CoreInjectionNavigationCoordinator, RegisterAndSignInCoordinatorProtocol {
    
    var firstViewController:UIViewController?
    
    init(parent: RegisterAndSignInCoordinatorParent?, navigationRouter: NavigationRoutingProtocol, inject: CoreInjectionProtocol) {
        super.init(parent: parent, navigationRouter: navigationRouter, inject: inject)
    }
    
    override func start() {
        presentRegisterUserViewController()
    }
    
    func onUserRegisteredAndCandidateCreated(pop: Bool = true) {
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
    
    func switchMode(_ mode: RegisterAndSignInMode) {
        switch mode {
        case .register:
            navigationRouter.pop(animated: true)
            break
        case .signIn:
            presentSignInUserViewController()
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
            mode: .register)
        
        let presenter = RegisterUserPresenter(
            coordinator: self,
            userRepository: userRepository,
            registerUserLogic: registerUserLogic)
        
        let vc = RegisterUserViewController(presenter: presenter)
        firstViewController = vc
        navigationRouter.push(viewController: vc, animated: true)
    }
    
    func presentSignInUserViewController() {
        let userRepository = injected.userRepository
        let registerUserLogic = RegisterUserLogic(
            networkConfig: injected.networkConfig,
            userRepository: userRepository,
            mode: .signIn)
        
        let presenter = SignInUserPresenter(
            coordinator: self,
            userRepository: userRepository,
            registerUserLogic: registerUserLogic)
        
        let vc = SignInViewController(presenter: presenter)
        navigationRouter.push(viewController: vc, animated: true)
    }
}
