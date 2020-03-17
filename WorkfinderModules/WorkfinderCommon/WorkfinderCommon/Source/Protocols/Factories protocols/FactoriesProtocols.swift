
import Foundation

public protocol TabbarCoordinatorFactoryProtocol {
    func makeTabBarCoordinator(parent: Coordinating,
    router: NavigationRoutingProtocol,
    inject: CoreInjectionProtocol) -> TabBarCoordinatorProtocol
}

public protocol F4SPlacementDocumentsServiceFactoryProtocol {
    func makePlacementDocumentsService(placementUuid: F4SUUID) -> F4SPlacementDocumentsServiceProtocol
}

public protocol OnboardingCoordinatorFactoryProtocol {
    func makeOnboardingCoordinator(parent: Coordinating?,
    navigationRouter: NavigationRoutingProtocol) -> OnboardingCoordinatorProtocol
}

public protocol EmailVerificationServiceFactoryProtocol {
    func makeEmailVerificationService() -> EmailVerificationServiceProtocol
}
