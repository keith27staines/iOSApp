
public protocol OnboardingCoordinatorFactoryProtocol {
    func makeOnboardingCoordinator(parent: Coordinating?,
    navigationRouter: NavigationRoutingProtocol) -> OnboardingCoordinatorProtocol
}
