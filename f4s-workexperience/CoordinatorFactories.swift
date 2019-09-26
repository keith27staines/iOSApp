
import WorkfinderCommon
import WorkfinderNetworking
import WorkfinderServices
import WorkfinderAppLogic
import WorkfinderUI
import WorkfinderOnboardingUseCase



class OnboardingCoordinatorFactory : OnboardingCoordinatorFactoryProtocol {
    
    let partnerService: F4SPartnerServiceProtocol
    let localStore: LocalStorageProtocol
    public init(partnerService: F4SPartnerServiceProtocol,
                localStore: LocalStorageProtocol) {
        self.partnerService = partnerService
        self.localStore = localStore
    }
    
    func makeOnboardingCoordinator(parent: Coordinating?,
                                   navigationRouter: NavigationRoutingProtocol) -> OnboardingCoordinatorProtocol {
        return OnboardingCoordinator(
            parent: parent,
            navigationRouter: navigationRouter,
            partnerService: partnerService,
            localStore: localStore)
    }
}
