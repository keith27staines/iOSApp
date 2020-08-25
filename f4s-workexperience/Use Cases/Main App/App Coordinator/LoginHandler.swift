
import UIKit
import WorkfinderCommon
import WorkfinderUI
import WorkfinderRegisterCandidate
import WorkfinderCoordinators

public class LoginHandler: CoreInjectionNavigationCoordinator {
    
    let mainWindow: UIWindow?
    var completion: ((Bool) -> Void)?
    var registerCoordinator: RegisterAndSignInCoordinator?
    
    init(parentCoordinator: Coordinating,
         navigationRouter: NavigationRoutingProtocol,
         mainWindow: UIWindow?,
         coreInjection: CoreInjectionProtocol
    ) {
        self.mainWindow = mainWindow
        super.init(parent: parentCoordinator, navigationRouter: navigationRouter, inject: coreInjection)
    }
    
    public func startLoginWorkflow(completion: @escaping (Bool) -> Void) {
        self.completion = completion
        self.loginWindow.makeKeyAndVisible()
        let coordinator = RegisterAndSignInCoordinator(
            parent: self,
            navigationRouter: newNavigationRouter,
            inject: injected,
            hideBackButton: true
        )
        addChildCoordinator(coordinator)
        coordinator.start()
    }
    
    func complete(signedIn: Bool) {
        if let coordinator = registerCoordinator {
            removeChildCoordinator(coordinator)
        }
        loginWindow.isHidden = true
        mainWindow?.makeKeyAndVisible()
        completion?(signedIn)
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
    
    public func onCandidateIsSignedIn() { complete(signedIn: true) }
    
    public func onRegisterAndSignInCancelled() { complete(signedIn: false) }
    
}
