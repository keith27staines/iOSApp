

import UIKit
import WorkfinderCommon
import WorkfinderUI
import WorkfinderRegisterCandidate

public class ErrorHandler: ErrorHandlerProtocol, Coordinating {
    
    public let uuid = UUID()
    public var childCoordinators: [UUID : Coordinating] = [:]
    public var parentCoordinator: Coordinating?
    let userRepository: UserRepositoryProtocol
    let navigationRouter: NavigationRoutingProtocol
    let coreInjection: CoreInjectionProtocol
    let messageHandler: UserMessageHandler? = nil
    var isSignedIn: Bool = false
    var presentingViewController: UIViewController?
    
    var retry: (() -> Void)?
    var cancel: (() -> Void)?
    
    public init(navigationRouter: NavigationRoutingProtocol, coreInjection: CoreInjectionProtocol, parentCoordinator: Coordinating?) {
        self.userRepository = coreInjection.userRepository
        self.parentCoordinator = parentCoordinator
        self.navigationRouter = navigationRouter
        self.coreInjection = coreInjection
    }
    
    public func start() {}
    
    public func startHandleError(
        _ error: Error?,
        presentingViewController: UIViewController,
        messageHandler: UserMessageHandler,
        cancel: @escaping (() -> Void),
        retry: @escaping (() -> Void)) {
        self.cancel = cancel
        self.retry = retry
        self.presentingViewController = presentingViewController
        messageHandler.hideLoadingOverlay()
        guard let error = error else { return }
        guard !isSignedIn, let workfinderError = error as? WorkfinderError, workfinderError.code == 401 else {
            messageHandler.displayOptionalErrorIfNotNil(error, cancelHandler: cancel, retryHandler: retry)
            return
        }
        signInandRetry()
    }
    
    func signInandRetry() {
        let register = RegisterAndSignInCoordinator(
            parent: self,
            navigationRouter: navigationRouter,
            inject: coreInjection,
            firstScreenHidesBackButton: false)
        addChildCoordinator(register)
        if UserRepository().isCandidateLoggedIn {
            register.startLoginFirst()
        } else {
            register.start()
        }
    }
}

extension ErrorHandler: RegisterAndSignInCoordinatorParent {
    public func onRegisterAndSignInCancelled() {
        cancel?()
    }
    
    
    public func onCandidateIsSignedIn(preferredNextScreen: PreferredNextScreen) {
        isSignedIn = true
        if let presentingViewController = presentingViewController {
            navigationRouter.popToViewController(presentingViewController, animated: true)
        }
        retry?()
    }
}
