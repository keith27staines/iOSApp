import Foundation
import WorkfinderCommon

public class NavigationRouter : NavigationRoutingProtocol {
    public let navigationController: UINavigationController
    public var rootViewController: UIViewController
    
    public func push(viewController: UIViewController, animated: Bool) {
        navigationController.pushViewController(viewController, animated: animated)
    }
    
    public func popToViewController(_ viewController: UIViewController, animated: Bool) {
        navigationController.popToViewController(viewController, animated: animated)
    }
    
    func popToRootViewController(animated: Bool) {
        navigationController.popToRootViewController(animated: animated)
    }
    
    public func pop(animated: Bool = true) {
        navigationController.popViewController(animated: true)
    }
    
    public func present(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
        navigationController.present(viewController, animated: animated, completion: completion)
    }
    
    public func dismiss(animated: Bool, completion: (() -> Void)?) {
        navigationController.dismiss(animated: animated, completion: nil)
    }
    
    
    public init(navigationController: UINavigationController) {
        rootViewController = navigationController
        self.navigationController = navigationController
    }
}
