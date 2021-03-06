
import UIKit
import WorkfinderCommon
import WorkfinderUI
import WorkfinderCoordinators

extension TabIndex {
    
    var title: String {
        switch self {
        case .applications: return "Applications"
        case .home: return "Discover"
        case .recommendations: return "Recommendations"
        case .account: return "Account"
        }
    }
    
    var image: UIImage? {
        switch self {
        case .applications:
            return UIImage(named: "applications")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        case .home:
            return UIImage(named: "discover_tab")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        case .recommendations:
            return UIImage(named: "recommendations")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        case .account:
            return UIImage(named: "account")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        }
    }
    
    func tabCoordinator(from tabBarCoordinator: TabBarCoordinator) -> CoreInjectionNavigationCoordinator {
        switch self {
        case .applications: return tabBarCoordinator.applicationsCoordinator
        case .home: return tabBarCoordinator.homeCoordinator
        case .recommendations: return tabBarCoordinator.recommendationsCoordinator
        case .account: return tabBarCoordinator.accountCoordinator
        }
    }
    
    func makeRouter() -> NavigationRouter {
        let navigationController = UINavigationController()
        navigationController.tabBarItem = UITabBarItem(title: title, image: image, selectedImage: nil)
        return NavigationRouter(navigationController: navigationController)
    }
}
