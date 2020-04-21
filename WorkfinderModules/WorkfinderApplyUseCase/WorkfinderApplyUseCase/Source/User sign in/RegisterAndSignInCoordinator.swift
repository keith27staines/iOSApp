
import Foundation
import WorkfinderCommon
import WorkfinderCoordinators

protocol RegisterAndSignInCoordinatorProtocol {
    func onDidRegister(user: User, pop: Bool)
}

protocol RegisterAndSignInCoordinatorParent: Coordinating {
    func onDidRegister(user: User, pop: Bool)
}

class RegisterAndSignInCoordinator: CoreInjectionNavigationCoordinator, RegisterAndSignInCoordinatorProtocol {
    
    init(parent: RegisterAndSignInCoordinatorParent?, navigationRouter: NavigationRoutingProtocol, inject: CoreInjectionProtocol) {
        super.init(parent: parent, navigationRouter: navigationRouter, inject: inject)
    }
    
    override func start() {
        let userRepository = injected.userRepository
        guard userRepository.loadAccessToken() == nil else {
            onDidRegister(user: userRepository.loadUser(), pop: false)
            return
        }
        let service = RegisterUserService(networkConfig: injected.networkConfig)
        let presenter = RegisterUserPresenter(
            coordinator: self,
            userRepository: userRepository,
            service: service)
        let vc = RegisterUserViewController(presenter: presenter)
        navigationRouter.push(viewController: vc, animated: true)
    }
    
    func onDidRegister(user: User, pop: Bool = true) {
        (parentCoordinator as? RegisterAndSignInCoordinatorParent)?.onDidRegister(user: user, pop: pop)
        parentCoordinator?.childCoordinatorDidFinish(self)
    }
}
