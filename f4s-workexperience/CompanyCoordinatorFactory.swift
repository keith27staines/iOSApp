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
    let documentServiceFactory: F4SPlacementDocumentsServiceFactoryProtocol
    let documentUploaderFactory: F4SDocumentUploaderFactoryProtocol
    let emailVerificationModel: F4SEmailVerificationModel
    let interestsRepository: F4SInterestsRepositoryProtocol
    let templateService: F4STemplateServiceProtocol

    init(applyService: ApplyServiceProtocol,
         hostsProvider: HostsProviderProtocol,
         documentServiceFactory: F4SPlacementDocumentsServiceFactoryProtocol,
         documentUploaderFactory: F4SDocumentUploaderFactoryProtocol,
         emailVerificationModel: F4SEmailVerificationModel,
         environment: EnvironmentType,
         interestsRepository: F4SInterestsRepositoryProtocol,
         templateService: F4STemplateServiceProtocol) {
        self.applyService = applyService
        self.hostsProvider = hostsProvider
        self.documentServiceFactory = documentServiceFactory
        self.documentUploaderFactory = documentUploaderFactory
        self.emailVerificationModel = emailVerificationModel
        self.environment = environment
        self.interestsRepository = interestsRepository
        self.templateService = templateService
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
            templateService: templateService,
            emailVerificationModel: emailVerificationModel,
            documentServiceFactory: documentServiceFactory,
            documentUploaderFactory: documentUploaderFactory,
            applyService: ApplyService(),
            hostsProvider: hostsProvider)
    }
}
