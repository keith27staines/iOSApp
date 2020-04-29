
import Foundation
import WorkfinderCommon
import WorkfinderServices
import WorkfinderCoordinators

protocol RegisterAndSignInCoordinatorProtocol {
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
        let userRepository = injected.userRepository
        let candidate = userRepository.loadCandidate()
        guard candidate.uuid == nil else {
            onUserRegisteredAndCandidateCreated(pop: false)
            return
        }
        let registerUserLogic = RegisterUserLogic(
            networkConfig: injected.networkConfig,
            userRepository: userRepository)
        
        let presenter = RegisterUserPresenter(
            coordinator: self,
            userRepository: userRepository,
            registerUserLogic: registerUserLogic)
        
        let vc = RegisterUserViewController(presenter: presenter)
        navigationRouter.push(viewController: vc, animated: true)
    }
    
    func onUserRegisteredAndCandidateCreated(pop: Bool = true) {
        (parentCoordinator as? RegisterAndSignInCoordinatorParent)?.onDidRegister(pop: pop)
        parentCoordinator?.childCoordinatorDidFinish(self)
    }
}
