import Foundation
import WorkfinderCommon
import WorkfinderCoordinators

public class UserDetailsCoordinator : CoreInjectionNavigationCoordinator {
    public var didFinish: ((UserDetailsCoordinator) -> Void)?
    public var userIsTooYoung: (() -> Void)?
    public var popOnCompletion: Bool = false
    
    weak var userDetailsViewController: UserDetailsViewController? = nil
    
    public override func start() {
        let userDetailsStoryboard = UIStoryboard(name: "UserDetails", bundle: __bundle)
        let userDetailsViewController = userDetailsStoryboard.instantiateViewController(withIdentifier: "UserDetailsViewController") as! UserDetailsViewController
        let user = injected.userRepository.load()
        let viewModel = UserDetailsViewModel(user: user, coordinator: self)
        userDetailsViewController.coordinator = self
        userDetailsViewController.inject(viewModel: viewModel, userRepository: injected.userRepository)
        navigationRouter.push(viewController: userDetailsViewController, animated: true)
        self.userDetailsViewController = userDetailsViewController
    }
    
    func userDetailsDidComplete() {
        if popOnCompletion { navigationRouter.pop(animated: false) }
        parentCoordinator?.childCoordinatorDidFinish(self)
        didFinish?(self)
    }
}
