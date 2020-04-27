
import Foundation
import WorkfinderCommon
import WorkfinderServices
import WorkfinderCoordinators

protocol RegisterAndSignInCoordinatorProtocol {
    func onDidRegister(pop: Bool)
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
        guard userRepository.loadAccessToken() == nil else {
            onDidRegister(pop: false)
            return
        }
        
        let registerUserLogic = RegisterUserLogic(
            networkConfig: injected.networkConfig,
            userStore: userRepository)
        
        let presenter = RegisterUserPresenter(
            coordinator: self,
            userRepository: userRepository,
            registerUserLogic: registerUserLogic)
        
        let vc = RegisterUserViewController(presenter: presenter)
        navigationRouter.push(viewController: vc, animated: true)
    }
    
    func onDidRegister(pop: Bool = true) {
        (parentCoordinator as? RegisterAndSignInCoordinatorParent)?.onDidRegister(pop: pop)
        parentCoordinator?.childCoordinatorDidFinish(self)
    }
}
