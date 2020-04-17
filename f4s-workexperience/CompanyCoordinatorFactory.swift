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
    let applyService: ApplyServiceProtocol
    let environment: EnvironmentType
    let hostsProvider: HostsProviderProtocol
    let interestsRepository: F4SInterestsRepositoryProtocol

    init(applyService: ApplyServiceProtocol,
         hostsProvider: HostsProviderProtocol,
         environment: EnvironmentType,
         interestsRepository: F4SInterestsRepositoryProtocol) {
        self.applyService = applyService
        self.hostsProvider = hostsProvider
        self.environment = environment
        self.interestsRepository = interestsRepository
    }

    func makeCompanyCoordinator(
        parent: CompanyCoordinatorParentProtocol,
        navigationRouter: NavigationRoutingProtocol,
        companyWorkplace: CompanyWorkplace,
        inject: CoreInjectionProtocol) -> CompanyCoordinatorProtocol {
        return CompanyCoordinator(
            parent: parent,
            navigationRouter: navigationRouter,
            companyWorkplace: companyWorkplace,
            inject: inject,
            environment: environment,
            interestsRepository: interestsRepository,
            applyService: ApplyService(),
            hostsProvider: hostsProvider)
    }
}
