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
        companyAndPin: CompanyAndPin,
        recommendedAssociationUuid: F4SUUID?,
        inject: CoreInjectionProtocol,
        appSource: AppSource,
        applicationFinished: @escaping ((PreferredDestination) -> Void)
        ) -> CoreInjectionNavigationCoordinatorProtocol {
        return CompanyDetailsCoordinator(
            parent: parent,
            navigationRouter: navigationRouter,
            workplace: companyAndPin,
            recommendedAssociationUuid: recommendedAssociationUuid,
            inject: inject,
            environment: environment,
            applyService: applyService,
            associationsProvider: associationsProvider,
            applicationFinished: applicationFinished,
            appSource: appSource)
    }
}
