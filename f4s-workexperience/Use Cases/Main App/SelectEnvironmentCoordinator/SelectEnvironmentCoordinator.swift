
import Foundation
import WorkfinderCommon
import WorkfinderCoordinators

public protocol SelectEnvironmentCoordinating : Coordinating {
    func userDidSelectEnvironment()
    var onEnvironmentSelected: ( () -> Void )? { get set }
}

public protocol SelectEnvironmentCoordinatorFactoryProtocol {
    func create(parent: Coordinating,
                router: NavigationRoutingProtocol,
                onEnvironmentSelected: @escaping (() -> Void)) -> SelectEnvironmentCoordinating
}


public class SelectEnvironmentCoordinator : SelectEnvironmentCoordinating {
    
    weak public var parentCoordinator: Coordinating?
    unowned var router: NavigationRoutingProtocol
    
    public var uuid: UUID
    
    public var childCoordinators: [UUID : Coordinating] = [:]
    
    public var onEnvironmentSelected: ( () -> Void )?
    
    public func start() {
        let vc = UIStoryboard(name: "SelectEnvironment", bundle: nil).instantiateInitialViewController() as! SelectEnvironmentViewController
        vc.coordinator = self
        router.present(vc, animated: true, completion: nil)
    }
    
    public func userDidSelectEnvironment() {
        onEnvironmentSelected?()
        router.dismiss(animated: true, completion: nil)
        parentCoordinator?.childCoordinatorDidFinish(self)
    }
    
    public init(parent: Coordinating, router: NavigationRoutingProtocol, onEnvironmentSelected: @escaping () -> Void) {
        self.uuid = UUID()
        self.parentCoordinator = parent
        self.router = router
        self.onEnvironmentSelected = onEnvironmentSelected
    }
}
