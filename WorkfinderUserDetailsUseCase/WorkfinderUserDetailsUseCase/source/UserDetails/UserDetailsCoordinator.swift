import Foundation
import WorkfinderCommon
import WorkfinderCoordinators

let __bundle = Bundle(identifier: "com.f4s.WorkfinderUserDetailsUseCase")!
var __environment: EnvironmentType = .production

public class UserDetailsCoordinator : CoreInjectionNavigationCoordinator {
    public var didFinish: ((UserDetailsCoordinator) -> Void)?
    public var userIsTooYoung: (() -> Void)?
    public var popOnCompletion: Bool = false
    
    weak var userDetailsViewController: UserDetailsViewController? = nil
    let emailVerificationModel: F4SEmailVerificationModelProtocol
    
    public init(parent: Coordinating?,
                navigationRouter: NavigationRoutingProtocol,
                inject: CoreInjectionProtocol,
                emailVerificationModel: F4SEmailVerificationModelProtocol,
                environment: EnvironmentType) {
        self.emailVerificationModel = emailVerificationModel
        super.init(parent: parent,
                   navigationRouter: navigationRouter,
                   inject: inject)
        __environment = environment
    }
    
    public override func start() {
        let userDetailsStoryboard = UIStoryboard(name: "UserDetails", bundle: __bundle)
        let userDetailsViewController = userDetailsStoryboard.instantiateViewController(withIdentifier: "UserDetailsViewController") as! UserDetailsViewController
        let user = injected.userRepository.loadCandidate()
        let viewModel = UserDetailsViewModel(user: user, coordinator: self)
        userDetailsViewController.coordinator = self
        userDetailsViewController.inject(
            viewModel: viewModel,
            userRepository: injected.userRepository,
            userService: injected.userService,
            emailVerificationModel: emailVerificationModel)
        navigationRouter.push(viewController: userDetailsViewController, animated: true)
        self.userDetailsViewController = userDetailsViewController
    }
    
    func userDetailsDidComplete() {
        if popOnCompletion { navigationRouter.pop(animated: false) }
        parentCoordinator?.childCoordinatorDidFinish(self)
        didFinish?(self)
    }
}
