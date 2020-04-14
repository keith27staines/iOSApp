
import Foundation
import WorkfinderCommon
import WorkfinderCoordinators

class UserSignInCoordinator: CoreInjectionNavigationCoordinator {
    
    override func start() {
        let userRepository = injected.userRepository
        let presenter = UserSigninPresenter(userRepository: userRepository)
        let vc = UserSigninViewController(presenter: presenter)
        navigationRouter.push(viewController: vc, animated: true)
    }
}
