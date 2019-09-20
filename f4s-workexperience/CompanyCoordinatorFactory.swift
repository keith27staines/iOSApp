import Foundation

import UIKit
import WorkfinderCommon
import WorkfinderNetworking
import WorkfinderServices
import WorkfinderCoordinators
import WorkfinderCompanyDetailsUseCase
import WorkfinderApplyUseCase
import WorkfinderUserDetailsUseCase

class CompanyCoordinatorFactory: CompanyCoordinatorFactoryProtocol {
    let environment: EnvironmentType
    let applyService: F4SPlacementApplicationServiceProtocol
    let companyFavouritesModel: CompanyFavouritesModel
    let companyService: F4SCompanyServiceProtocol
    let companyDocumentService: F4SCompanyDocumentServiceProtocol
    let documentServiceFactory: F4SPlacementDocumentsServiceFactoryProtocol
    let documentUploaderFactory: F4SDocumentUploaderFactoryProtocol
    let emailVerificationModel: F4SEmailVerificationModel
    let getAllPlacementsService: F4SGetAllPlacementsServiceProtocol
    let interestsRepository: F4SInterestsRepositoryProtocol
    let placementRepository: F4SPlacementRepositoryProtocol
    let shareTemplateProvider: ShareTemplateProviderProtocol
    let templateService: F4STemplateServiceProtocol

    init(applyService: F4SPlacementApplicationServiceProtocol,
         companyFavouritesModel: CompanyFavouritesModel,
         companyService: F4SCompanyServiceProtocol,
         companyDocumentService: F4SCompanyDocumentServiceProtocol,
         documentServiceFactory: F4SPlacementDocumentsServiceFactoryProtocol,
         documentUploaderFactory: F4SDocumentUploaderFactoryProtocol,
         emailVerificationModel: F4SEmailVerificationModel,
         environment: EnvironmentType,
         getAllPlacementsService: F4SGetAllPlacementsServiceProtocol,
         interestsRepository: F4SInterestsRepositoryProtocol,
         placementRepository: F4SPlacementRepositoryProtocol,
         shareTemplateProvider: ShareTemplateProviderProtocol,
         templateService: F4STemplateServiceProtocol) {
        self.applyService = applyService
        self.companyFavouritesModel = companyFavouritesModel
        self.companyService = companyService
        self.companyDocumentService = companyDocumentService
        self.documentServiceFactory = documentServiceFactory
        self.documentUploaderFactory = documentUploaderFactory
        self.emailVerificationModel = emailVerificationModel
        self.environment = environment
        self.getAllPlacementsService = getAllPlacementsService
        self.interestsRepository = interestsRepository
        self.placementRepository = placementRepository
        self.shareTemplateProvider = shareTemplateProvider
        self.templateService = templateService
    }
    
    func makeCompanyCoordinator(parent: CompanyCoordinatorParentProtocol, navigationRouter: NavigationRoutingProtocol, inject: CoreInjectionProtocol, companyUuid: F4SUUID) ->  CompanyCoordinatorProtocol? {
        guard let company = F4SCompanyRepository().load(companyUuid: companyUuid) else { return nil }
        return makeCompanyCoordinator(parent: parent, navigationRouter: navigationRouter, company: company, inject: inject)
    }
    
    func makeCompanyCoordinator(
        parent: CompanyCoordinatorParentProtocol,
        navigationRouter: NavigationRoutingProtocol,
        company: Company,
        inject: CoreInjectionProtocol) -> CompanyCoordinatorProtocol {
        let socialShareItemSource = SocialShareItemSource(
            company: company,
            shareTemplateProvider: shareTemplateProvider)
        return CompanyCoordinator(
            parent: parent,
            navigationRouter: navigationRouter,
            company: company,
            inject: inject,
            environment: environment,
            placementsRepository: placementRepository,
            interestsRepository: interestsRepository,
            socialShareItemSource: socialShareItemSource,
            favouritesModel: companyFavouritesModel,
            templateService: templateService,
            getAllPlacementsService: getAllPlacementsService,
            emailVerificationModel: emailVerificationModel,
            documentServiceFactory: documentServiceFactory,
            documentUploaderFactory: documentUploaderFactory,
            applyService: applyService,
            companyService: companyService,
            companyDocumentService: companyDocumentService)
    }
}

class ShareTemplateProvider: ShareTemplateProviderProtocol {
    func getBusinessesSocialShareTemplateOfType(_ type: SocialShare) -> String {
        return DatabaseOperations.sharedInstance.getBusinessesSocialShareTemplateOfType(type: type)
    }
    
    func getBusinessesSocialShareSubjectTemplateOfType(_ type: SocialShare) -> String {
        return DatabaseOperations.sharedInstance.getBusinessesSocialShareSubjectTemplateOfType(type: type)
    }
}
