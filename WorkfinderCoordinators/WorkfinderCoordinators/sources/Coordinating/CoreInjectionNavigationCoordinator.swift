import Foundation
import WorkfinderCommon
import WorkfinderUI

/// A suitable base class for coordinators representing tabs on a tabbar
open class CoreInjectionNavigationCoordinator : NavigationCoordinator {
    public let injected: CoreInjectionProtocol
    var log: F4SAnalyticsAndDebugging { return injected.log }
    
    public init(parent: Coordinating?, navigationRouter: NavigationRoutingProtocol, inject: CoreInjectionProtocol) {
        injected = inject
        super.init(parent: parent, navigationRouter: navigationRouter)
    }
    
    public func presentContent(_ contentType: F4SContentType) {
        let contentViewController = WorkfinderUI().makeWebContentViewController(contentType: contentType, dismissByPopping: true, contentService: injected.contentService)
        navigationRouter.navigationController.pushViewController(contentViewController, animated: true)
    }
}

extension CoreInjectionNavigationCoordinator : CoreInjectionNavigationCoordinatorProtocol {}
