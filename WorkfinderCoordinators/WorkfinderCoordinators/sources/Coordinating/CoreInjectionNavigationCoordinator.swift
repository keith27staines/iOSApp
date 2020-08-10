import Foundation
import WorkfinderCommon
import WorkfinderUI

open class CoreInjectionNavigationCoordinator : NavigationCoordinator {
    public let injected: CoreInjectionProtocol
    var log: F4SAnalyticsAndDebugging { return injected.log }
    
    public init(parent: Coordinating?, navigationRouter: NavigationRoutingProtocol, inject: CoreInjectionProtocol) {
        injected = inject
        super.init(parent: parent, navigationRouter: navigationRouter)
    }
    
    public func presentContent(_ contentType: WorkfinderContentType) {
        let url = contentType.url
        switch contentType.openingMode {
        case .inWorkfinder:
            let contentViewController = WebViewController(
                url: url,
                showNavigationButtons: true,
                delegate: self)
            navigationRouter.navigationController.pushViewController(contentViewController, animated: true)
        case .inBrowser:
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

extension CoreInjectionNavigationCoordinator : CoreInjectionNavigationCoordinatorProtocol {}

extension CoreInjectionNavigationCoordinator: WebViewControllerDelegate {
    public func webViewControllerDidFinish(_ vc: WebViewController) {
        vc.dismiss(animated: true, completion: nil)
    }
    
    
}
