
import XCTest
import WorkfinderCommon
@testable import f4s_workexperience

class TabBarCoordinatorTests: XCTestCase {
    
    var builder = TestMasterBuilder(userIsRegistered: true, versionIsOkay: true)
    var parent: MockParentCoordinator!
    
    func test_start() {
        let sut = makeSut()
        sut.start()
        XCTAssertNotNil(sut.childCoordinators)
    }
    
    func makeSut() -> TabBarCoordinator {
        let router = MockNavigationRouter()
        let inject = builder.inject
        parent = MockParentCoordinator(router: router)
        return TabBarCoordinator(
            parent: parent,
            navigationRouter: router,
            inject: inject,
            companyCoordinatorFactory: builder.mockCompanyCoordinatorFactory,
            companyDocumentsService: builder.mockCompanyDocumentsService,
            companyRepository: builder.mockCompanyRepository,
            companyService: builder.mockCompanyService,
            favouritesRepository: builder.mockFavouritesRepository,
            documentUploaderFactory: builder.mockDocumentUploaderFactory,
            interestsRepository: builder.interestsRepository,
            offerProcessingService: builder.mockOfferProcessingService,
            partnersModel: builder.mockPartnersModel,
            placementsRepository: builder.mockPlacementsRepository,
            placementService: builder.mockPlacementService,
            placementDocumentsServiceFactory: builder.mockPlacementDocumentsServiceFactory,
            messageServiceFactory: builder.mockMessageServiceFactory,
            messageActionServiceFactory: builder.mockMessageActionServiceFactory,
            messageCannedResponsesServiceFactory: builder.mockMessageCannedResponsesServiceFactory,
            recommendationsService: builder.mockRecommendationsService,
            roleService: builder.mockRoleService)
    }
}
