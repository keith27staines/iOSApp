
import UIKit
import WorkfinderUI
import WorkfinderCoordinators

enum TabIndex : Int, CaseIterable {
    
    // The order of the cases will determine the order of the tabs on the tab bar
    case applications
    case map
    case recommendations
    
    var title: String {
        switch self {
        case .applications: return "Applications"
        case .map: return "Search"
        case .recommendations: return "Recommendations"
        }
    }
    
    var image: UIImage? {
        switch self {
        case .applications:
            return UIImage(named: "applications")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        case .map:
            return UIImage(named: "searchIcon")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        case .recommendations:
            return UIImage(named: "recommendations")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        }
    }
    
    func tabCoordinator(from tabBarCoordinator: TabBarCoordinator) -> CoreInjectionNavigationCoordinator {
        switch self {
        case .applications: return tabBarCoordinator.applicationsCoordinator
        case .map: return tabBarCoordinator.searchCoordinator
        case .recommendations: return tabBarCoordinator.recommendationsCoordinator
        }
    }
    
    func makeRouter() -> NavigationRouter {
        let navigationController = UINavigationController()
        navigationController.tabBarItem = UITabBarItem(title: title, image: image, selectedImage: nil)
        return NavigationRouter(navigationController: navigationController)
    }
}
