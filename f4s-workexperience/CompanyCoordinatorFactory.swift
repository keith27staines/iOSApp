import Foundation

import UIKit
import WorkfinderCommon
import WorkfinderNetworking
import WorkfinderServices
import WorkfinderCoordinators
import WorkfinderCompanyDetailsUseCase
import WorkfinderAppLogic
import WorkfinderApplyUseCase
import WorkfinderUserDetailsUseCase

class CompanyCoordinatorFactory: CompanyCoordinatorFactoryProtocol {
    let applyService: PostPlacementServiceProtocol
    let environment: EnvironmentType
    let associationsProvider: AssociationsServiceProtocol
    let interestsRepository: F4SSelectedInterestsRepositoryProtocol

    init(applyService: PostPlacementServiceProtocol,
         associationsProvider: AssociationsServiceProtocol,
         environment: EnvironmentType,
         interestsRepository: F4SSelectedInterestsRepositoryProtocol) {
        self.applyService = applyService
        self.associationsProvider = associationsProvider
        self.environment = environment
        self.interestsRepository = interestsRepository
    }

    func buildCoordinator(
        parent: CompanyCoordinatorParentProtocol,
        navigationRouter: NavigationRoutingProtocol,
        workplace: Workplace,
        inject: CoreInjectionProtocol,
        applicationFinished: @escaping ((PreferredDestination) -> Void)
        ) -> CoreInjectionNavigationCoordinatorProtocol {
        return CompanyDetailsCoordinator(
            parent: parent,
            navigationRouter: navigationRouter,
            workplace: workplace,
            inject: inject,
            environment: environment,
            interestsRepository: interestsRepository,
            applyService: applyService,
            associationsProvider: associationsProvider,
            applicationFinished: applicationFinished)
    }
}
