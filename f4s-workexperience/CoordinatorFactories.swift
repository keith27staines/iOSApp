
import WorkfinderCommon
import WorkfinderNetworking
import WorkfinderServices
import WorkfinderAppLogic
import WorkfinderUI
import WorkfinderOnboardingUseCase



class OnboardingCoordinatorFactory : OnboardingCoordinatorFactoryProtocol {
    
    let partnerService: F4SPartnerServiceProtocol
    public init(partnerService: F4SPartnerServiceProtocol) {
        self.partnerService = partnerService
    }
    
    func makeOnboardingCoordinator(parent: Coordinating?,
                                   navigationRouter: NavigationRoutingProtocol) -> OnboardingCoordinatorProtocol {
        return OnboardingCoordinator(
            parent: parent,
            navigationRouter: navigationRouter,
            partnerService: partnerService)
    }
}

