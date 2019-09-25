
import UIKit

public class MockNavigationRouter : NavigationRoutingProtocol {
    
    public private (set) var pushedViewControllers = [UIViewController]()
    public private (set) var presentedViewControllers = [UIViewController]()
    var dismissCount: Int = 0
    
    public init() {}
    
    public func pop(animated: Bool) {
        pushedViewControllers.removeLast()
    }
    
    public func popToViewController(_ viewController: UIViewController, animated: Bool) {
        
    }
    
    public var navigationController: UINavigationController = UINavigationController()
    
    public func push(viewController: UIViewController, animated: Bool = false) {
        pushedViewControllers.append(viewController)
    }
    
    public func present(_ viewController: UIViewController, animated: Bool = false, completion: (() -> Void)? = nil) {
        presentedViewControllers.append(viewController)
    }
    
    public func dismiss(animated: Bool, completion: (() -> Void)? = nil) {
        guard presentedViewControllers.count > 0 else { return }
        presentedViewControllers.removeLast()
    }
    
    public var rootViewController: UIViewController = UIViewController()

}




