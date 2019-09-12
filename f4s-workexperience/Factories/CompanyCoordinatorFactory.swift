import Foundation

import UIKit
import WorkfinderCommon
import WorkfinderNetworking
import WorkfinderServices
import WorkfinderCoordinators
import WorkfinderCompanyDetailsUseCase
import WorkfinderApplyUseCase

class CompanyCoordinatorFactory: CompanyCoordinatorFactoryProtocol {
    
    func makeCompanyCoordinator(parent: CompanyCoordinatorParentProtocol, navigationRouter: NavigationRoutingProtocol, inject: CoreInjectionProtocol, companyUuid: F4SUUID) ->  CompanyCoordinatorProtocol? {
        guard let company = F4SCompanyRepository().load(companyUuid: companyUuid) else { return nil }
        return makeCompanyCoordinator(parent: parent, navigationRouter: navigationRouter, company: company, inject: inject)
    }
    
    func makeCompanyCoordinator(
        parent: CompanyCoordinatorParentProtocol,
        navigationRouter: NavigationRoutingProtocol,
        company: Company,
        inject: CoreInjectionProtocol) -> CompanyCoordinatorProtocol {
        let placementRepository = F4SPlacementRespository()
        let interestsRepository = F4SInterestsRepository()
        let shareTemplateProvider = ShareTemplateProvider()
        let socialShareItemSource = SocialShareItemSource(company: company, shareTemplateProvider: shareTemplateProvider)
        let favouritingService = F4SCompanyFavouritingService()
        let favouritesRepository = F4SFavouritesRepository()
        let favouritesModel = CompanyFavouritesModel(favouritingService: favouritingService, favouritesRepository: favouritesRepository)
        return CompanyCoordinator(
            parent: parent,
            navigationRouter: navigationRouter,
            company: company,
            inject: inject,
            placementsRepository: placementRepository,
            interestsRepository: interestsRepository,
            socialShareItemSource: socialShareItemSource,
            favouritesModel: favouritesModel)
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
