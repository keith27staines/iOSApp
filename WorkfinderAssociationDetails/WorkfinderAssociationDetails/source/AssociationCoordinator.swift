
import Foundation
import WorkfinderCommon
import WorkfinderCoordinators

protocol AssociationCoordinatorProtocol {
    
}

public class AssociationCoordinator: CoreInjectionNavigationCoordinator {
    
    let associationUuid: F4SUUID
    
    override public func start() {
        
    }
    
    public init(associationUuid: F4SUUID,
                parent: Coordinating?,
                navigationRouter: NavigationRoutingProtocol,
                inject: CoreInjectionProtocol) {
        self.associationUuid = associationUuid
        super.init(parent: parent, navigationRouter: navigationRouter, inject: inject)
    }
    
    
    
}
