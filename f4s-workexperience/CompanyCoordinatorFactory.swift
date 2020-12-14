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

    init(applyService: PostPlacementServiceProtocol,
         associationsProvider: AssociationsServiceProtocol,
         environment: EnvironmentType) {
        self.applyService = applyService
        self.associationsProvider = associationsProvider
        self.environment = environment
    }

    func buildCoordinator(
        parent: CompanyCoordinatorParentProtocol,
        navigationRouter: NavigationRoutingProtocol,
        workplace: CompanyAndPin,
        recommendedAssociationUuid: F4SUUID?,
        inject: CoreInjectionProtocol,
        applicationFinished: @escaping ((PreferredDestination) -> Void)
        ) -> CoreInjectionNavigationCoordinatorProtocol {
        return CompanyDetailsCoordinator(
            parent: parent,
            navigationRouter: navigationRouter,
            workplace: workplace,
            recommendedAssociationUuid: recommendedAssociationUuid,
            inject: inject,
            environment: environment,
            applyService: applyService,
            associationsProvider: associationsProvider,
            applicationFinished: applicationFinished)
    }
}
