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
    let associationsProvider: HostLocationAssociationsServiceProtocol
    let interestsRepository: F4SInterestsRepositoryProtocol

    init(applyService: PostPlacementServiceProtocol,
         associationsProvider: HostLocationAssociationsServiceProtocol,
         environment: EnvironmentType,
         interestsRepository: F4SInterestsRepositoryProtocol) {
        self.applyService = applyService
        self.associationsProvider = associationsProvider
        self.environment = environment
        self.interestsRepository = interestsRepository
    }

    func makeCompanyCoordinator(
        parent: CompanyCoordinatorParentProtocol,
        navigationRouter: NavigationRoutingProtocol,
        companyWorkplace: CompanyWorkplace,
        inject: CoreInjectionProtocol,
        applicationFinished: @escaping ((PreferredDestination) -> Void)
        ) -> CompanyCoordinatorProtocol {
        return CompanyCoordinator(
            parent: parent,
            navigationRouter: navigationRouter,
            companyWorkplace: companyWorkplace,
            inject: inject,
            environment: environment,
            interestsRepository: interestsRepository,
            applyService: applyService,
            associationsProvider: associationsProvider,
            applicationFinished: applicationFinished)
    }
}
