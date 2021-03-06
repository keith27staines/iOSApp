
import WorkfinderCommon
import WorkfinderNetworking
import WorkfinderServices
import WorkfinderAppLogic
import WorkfinderUI
import WorkfinderOnboardingUseCase

class OnboardingCoordinatorFactory : OnboardingCoordinatorFactoryProtocol {
    
    
    let localStore: LocalStorageProtocol
    public init(localStore: LocalStorageProtocol) {
        self.localStore = localStore
    }
    
    func makeOnboardingCoordinator(parent: Coordinating?,
                                   navigationRouter: NavigationRoutingProtocol,
                                   inject: CoreInjectionProtocol,
                                   log: F4SAnalytics) -> OnboardingCoordinatorProtocol {
        return OnboardingCoordinator(
            parent: parent,
            navigationRouter: navigationRouter,
            localStore: localStore,
            log: log,
            inject: inject)
    }
}

