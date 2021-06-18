
import UIKit
import WorkfinderCommon
import WorkfinderUI
import WorkfinderCoordinators

public class LoginHandler: CoreInjectionNavigationCoordinator {
    
    let mainWindow: UIWindow?
    var completion: ((Bool, PreferredNextScreen) -> Void)?
    var registerCoordinator: RegisterAndSignInCoordinator?
    
    public init(parentCoordinator: Coordinating,
         navigationRouter: NavigationRoutingProtocol,
         mainWindow: UIWindow?,
         coreInjection: CoreInjectionProtocol
    ) {
        self.mainWindow = mainWindow
        super.init(parent: parentCoordinator, navigationRouter: navigationRouter, inject: coreInjection)
    }

    
    public func startLoginWorkflow(screenOrder: SignInScreenOrder, completion: @escaping (Bool, PreferredNextScreen) -> Void) {
        self.completion = completion
        self.loginWindow.makeKeyAndVisible()
        let coordinator = RegisterAndSignInCoordinator(
            parent: self,
            navigationRouter: newNavigationRouter,
            inject: injected,
            firstScreenHidesBackButton: true
        )
        addChildCoordinator(coordinator)
        switch screenOrder {
        case .loginThenRegister:
            coordinator.startLoginFirst()
        case .registerThenLogin:
            coordinator.startRegisterFirst()
        }
    }
    
    func complete(signedIn: Bool, preferredNextScreen: PreferredNextScreen) {
        if let coordinator = registerCoordinator {
            removeChildCoordinator(coordinator)
        }
        loginWindow.isHidden = true
        mainWindow?.makeKeyAndVisible()
        completion?(signedIn, preferredNextScreen)
    }
    
    lazy var rootViewController: UIViewController = {
        let vc = UIViewController()
        vc.view.backgroundColor = UIColor.white
        return vc
    }()
    lazy var navigationController = UINavigationController(rootViewController: self.rootViewController)
    lazy var newNavigationRouter = NavigationRouter(navigationController: self.navigationController)
    lazy var loginWindow: UIWindow = {
        let window = UIWindow()
        window.rootViewController = navigationController
        window.backgroundColor = UIColor.white
        window.windowLevel = .statusBar
        return window
    }()
}

extension LoginHandler: RegisterAndSignInCoordinatorParent {
    
    public func onCandidateIsSignedIn(preferredNextScreen: PreferredNextScreen) {
        complete(signedIn: true, preferredNextScreen: preferredNextScreen)
    }
    
    public func onRegisterAndSignInCancelled() { complete(signedIn: false, preferredNextScreen: .noOpinion) }
    
}
