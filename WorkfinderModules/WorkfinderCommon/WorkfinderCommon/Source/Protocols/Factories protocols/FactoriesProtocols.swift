
import Foundation

public protocol TabbarCoordinatorFactoryProtocol {
    func makeTabBarCoordinator(parent: Coordinating,
    router: NavigationRoutingProtocol,
    inject: CoreInjectionProtocol) -> TabBarCoordinatorProtocol
}

public protocol OnboardingCoordinatorFactoryProtocol {
    func makeOnboardingCoordinator(parent: Coordinating?,
    navigationRouter: NavigationRoutingProtocol) -> OnboardingCoordinatorProtocol
}

