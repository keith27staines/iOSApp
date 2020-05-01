
import Foundation
import WorkfinderCommon
import WorkfinderServices
import WorkfinderCoordinators

protocol RegisterAndSignInCoordinatorProtocol {
    func switchMode(_ mode: RegisterAndSignInMode)
    func onUserRegisteredAndCandidateCreated(pop: Bool)
}

protocol RegisterAndSignInCoordinatorParent: Coordinating {
    func onDidRegister(pop: Bool)
}

class RegisterAndSignInCoordinator: CoreInjectionNavigationCoordinator, RegisterAndSignInCoordinatorProtocol {
    
    init(parent: RegisterAndSignInCoordinatorParent?, navigationRouter: NavigationRoutingProtocol, inject: CoreInjectionProtocol) {
        super.init(parent: parent, navigationRouter: navigationRouter, inject: inject)
    }
    
    override func start() {
        presentRegisterUserViewController()
    }
    
    func onUserRegisteredAndCandidateCreated(pop: Bool = true) {
        (parentCoordinator as? RegisterAndSignInCoordinatorParent)?.onDidRegister(pop: pop)
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
