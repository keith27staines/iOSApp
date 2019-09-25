
import Foundation

public class MockCompanyCoordinatorFactory: CompanyCoordinatorFactoryProtocol {
    public func makeCompanyCoordinator(
        parent: CompanyCoordinatorParentProtocol,
        navigationRouter: NavigationRoutingProtocol,
        inject: CoreInjectionProtocol,
        companyUuid: F4SUUID) -> CompanyCoordinatorProtocol? {
        return MockCompanyCoordinator(
            parent: parent,
            navigationRouter: navigationRouter,
            inject: inject,
            companyUuid: companyUuid)
    }
    
    public func makeCompanyCoordinator(
        parent: CompanyCoordinatorParentProtocol,
        navigationRouter: NavigationRoutingProtocol,
        company: Company,
        inject: CoreInjectionProtocol) -> CompanyCoordinatorProtocol {
        return MockCompanyCoordinator(
            parent: parent,
            navigationRouter: navigationRouter,
            inject: inject,
            company: company)
    }
}

public class MockCompanyCoordinator: CompanyCoordinatorProtocol {
    public let uuid = UUID()
    public var injected: CoreInjectionProtocol
    public var parentCoordinator: Coordinating?
    public var childCoordinators: [UUID : Coordinating] = [:]
    public var navigationRouter: NavigationRoutingProtocol
    public let companyUuid: F4SUUID
    public var company: Company?
    
    public func start() {
        
    }
    
    public init(parent: CompanyCoordinatorParentProtocol,
                navigationRouter: NavigationRoutingProtocol,
                inject: CoreInjectionProtocol,
                company: Company) {
        self.parentCoordinator = parent
        self.injected = inject
        self.navigationRouter = navigationRouter
        self.company = company
        self.companyUuid = company.uuid
    }
    
    public init(parent: CompanyCoordinatorParentProtocol,
                navigationRouter: NavigationRoutingProtocol,
                inject: CoreInjectionProtocol,
                companyUuid: F4SUUID) {
        self.parentCoordinator = parent
        self.injected = inject
        self.navigationRouter = navigationRouter
        self.companyUuid = companyUuid
    }
}

public class MockF4SCompanyDatabaseMetadataService : F4SCompanyDatabaseMetadataServiceProtocol {
    public func getDatabaseMetadata(completion: @escaping (F4SNetworkResult<F4SCompanyDatabaseMetaData>) -> ()) {
    
    }
    
    public init() {}
}

public class MockF4SVersionCheckingService: F4SWorkfinderVersioningServiceProtocol {
    
    var versionIsGood: Bool
    
    public func getIsVersionValid(version: String, completion: @escaping (F4SNetworkResult<F4SVersionValidity>) -> ()) {
        let result = F4SNetworkResult.success(versionIsGood)
        completion(result)
    }
    
    public init(versionIsGood: Bool) {
        self.versionIsGood = versionIsGood
    }
}

public class MockUserStatusService : F4SUserStatusServiceProtocol {
    public var userStatus: F4SUserStatus?
    
    public func beginStatusUpdate() {}
    
    public func getUserStatus(completion: @escaping (F4SNetworkResult<F4SUserStatus>) -> ()) {
        let status = F4SUserStatus(unreadMessageCount: 1, unratedPlacements: [])
        let result = F4SNetworkResult.success(status)
        completion(result)
    }
}

///

public class MockF4SPartnerService: F4SPartnerServiceProtocol {
    public func getPartners(completion: @escaping (F4SNetworkResult<[F4SPartner]>) -> ()) {
        
    }
    
    public init() {}
    
}

public class MockF4SPlacementDocumentsServiceFactory : F4SPlacementDocumentsServiceFactoryProtocol {
    public init() {}
    public func makePlacementDocumentsService(placementUuid: F4SUUID) -> F4SPlacementDocumentsServiceProtocol {
        return MockF4SPlacementDocumentsService()
    }
}

public class MockF4SPlacementDocumentsService: F4SPlacementDocumentsServiceProtocol {
    
    public init() {}
    
    public func getDocuments(completion: @escaping (F4SNetworkResult<F4SGetDocumentJson>) -> ()) {
        
    }
    
    public func putDocuments(documents: F4SPutDocumentsJson, completion: @escaping ((F4SNetworkResult<F4SJSONBoolValue>) -> Void)) {
    }
}

public class MockF4SDocumentUploaderFactory: F4SDocumentUploaderFactoryProtocol {
    public func makeDocumentUploader(document: F4SDocument, placementuuid: F4SUUID) -> F4SDocumentUploaderProtocol? {
        return MockF4SDocumentUploader()
    }
    
    public init() {}
}

public class MockF4SDocumentUploader: F4SDocumentUploaderProtocol {
    public var delegate: F4SDocumentUploaderDelegate?
    
    public var state: DocumentUploadState = .waiting
    
    public func cancel() {
        
    }
    
    public func resume() {
        
    }
}


public class MockF4SEmailVerificationModel: F4SEmailVerificationModelProtocol {
    public var lastNonErrorState: F4SEmailVerificationState = .start
    
    public var emailVerificationState: F4SEmailVerificationState = .start
    
    public var verifiedEmail: String?
    
    public var emailSentForVerification: String?
    
    public var didChangeState: ((F4SEmailVerificationState, F4SEmailVerificationState) -> Void)?
    
    public init() {}
    
    public func basicEmailFormatValidator(email: String?) -> Bool {
        return true
    }
    
    public func isEmailAddressVerified(email: String?) -> Bool {
        return false
    }
    
    public func restart() {
        
    }
    
    public func submitEmailForVerification(_ email: String, completion: @escaping (() -> Void)) {
        
    }
    
    public func stagingBypassSetVerifiedEmail(email: String) {
        
    }
}

public class MockAppInstallationUuidLogic: AppInstallationUuidLogicProtocol {
    public var registeredInstallationUuid: F4SUUID?
    public init(registeredInstallationUuid: F4SUUID? = nil) {
        self.registeredInstallationUuid = registeredInstallationUuid
    }
    
    public func ensureDeviceIsRegistered(completion: @escaping (F4SNetworkResult<F4SRegisterDeviceResult>) -> ()) {
    }
}

public class MockF4SGetAllPlacementsService: F4SGetAllPlacementsServiceProtocol {
    
    var result: F4SNetworkResult<[F4STimelinePlacement]>
    
    public init(result: F4SNetworkResult<[F4STimelinePlacement]>) {
        self.result = result
    }
    
    public func getAllPlacementsForUser(completion: @escaping (F4SNetworkResult<[F4STimelinePlacement]>) -> ()) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            completion(strongSelf.result)
        }
    }
}

public class MockF4SCompanyDocumentsModel: F4SCompanyDocumentsModelProtocol {
    public var documents: F4SCompanyDocuments = []
    
    public var availableDocuments: F4SCompanyDocuments = []
    
    public var requestableDocuments: F4SCompanyDocuments = []
    
    public var unavailableDocuments: F4SCompanyDocuments = []
    
    public init() {}
    
    public func rowsInSection(section: Int) -> Int {
        return 0
    }
    
    public func updateUserIsRequestingState(document: F4SCompanyDocument, isRequesting: Bool) -> F4SCompanyDocument? {
        return nil
    }
    
    public func document(_ indexPath: IndexPath) -> F4SCompanyDocument? {
        return nil
    }
    
    public func getDocuments(age: Int, completion: @escaping (F4SNetworkResult<F4SCompanyDocuments>) -> ()) {
        
    }
    
    public func requestDocumentsFromCompany(completion: @escaping (F4SNetworkResult<F4SJSONBoolValue>) -> ()) {
        
    }
}

public class MockAllowedToApplyLogic: AllowedToApplyLogicProtocol {
    public var draftTimelinePlacement: F4STimelinePlacement?
    
    public var draftPlacement: F4SPlacement?
    
    public init() {}
    
    public func checkUserCanApply(user: F4SUUID?, to company: F4SUUID, givenExistingPlacements existing: [F4STimelinePlacement], completion: @escaping (F4SNetworkResult<Bool>) -> Void) {
        
    }
    
    public func checkUserCanApply(user: F4SUUID?, to company: F4SUUID, completion: @escaping (F4SNetworkResult<Bool>) -> Void) {
        
    }
}

public class MockF4SCompanyService: F4SCompanyServiceProtocol {
    public init() {}
    
    public func getCompany(uuid: F4SUUID, completion: @escaping (F4SNetworkResult<F4SCompanyJson>) -> ()) {
    
    }
}

public class MockFavouritingRepository: F4SFavouritesRepositoryProtocol {
    
    public init() {
        
    }
    
    var favourites = [F4SUUID: Shortlist]()
    
    public func loadFavourites() -> [Shortlist] {
        return Array(favourites.values)
    }
    
    public func removeFavourite(uuid: F4SUUID) {
        favourites[uuid] = nil
    }
    
    public func addFavourite(_ item: Shortlist) {
        favourites[item.uuid] = item
    }
}

public class MockFavouritingService: CompanyFavouritingServiceProtocol {
    public var apiName: String = "MockFavouritingService/api"
    var expectedFavouriteResult: F4SNetworkResult<F4SShortlistJson>
    var expectedUnfavouriteResult: F4SNetworkResult<F4SUUID>
    
    public init(expectedFavouriteResult: F4SNetworkResult<F4SShortlistJson>,
                expectedUnfavouriteResult: F4SNetworkResult<F4SUUID>) {
        self.expectedFavouriteResult = expectedFavouriteResult
        self.expectedUnfavouriteResult = expectedUnfavouriteResult
    }
    
    public func favourite(companyUuid: F4SUUID, completion: @escaping (F4SNetworkResult<F4SShortlistJson>) -> Void) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            completion(strongSelf.expectedFavouriteResult)
        }
    }
    
    public func unfavourite(shortlistUuid: String, completion: @escaping (F4SNetworkResult<F4SUUID>) -> Void) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            completion(strongSelf.expectedUnfavouriteResult)
        }
    }
}

public class MockF4SContentService: F4SContentServiceProtocol {
    public init() {}
    public func getContent(completion: @escaping (F4SNetworkResult<[F4SContentDescriptor]>) -> ()) {
        
    }
}

public class MockF4SDeviceRegistrationService : F4SDeviceRegistrationServiceProtocol {
    public init() {}
    public func registerDevice(anonymousUser: F4SAnonymousUser, completion: @escaping ((F4SNetworkResult<F4SRegisterDeviceResult>) -> ())) {
        
    }
}

public class MockF4SPlacementServiceFactory : F4SPlacementApplicationServiceFactoryProtocol {
    var successJson: F4SPlacementJson?
    let responseStatusCode: HTTPStatusCode
    
    public init(successCreatePlacementJson: F4SPlacementJson) {
        self.successJson = successCreatePlacementJson
        self.responseStatusCode = 200
    }
    
    public init(errorResponseCode: HTTPStatusCode) {
        self.responseStatusCode = errorResponseCode
    }
    
    public func makePlacementService() -> F4SPlacementApplicationServiceProtocol {
        let url = URL(string: "somewhere.com")!
        let httpResponse = HTTPURLResponse(url: url, statusCode: responseStatusCode, httpVersion: "1.0", headerFields: nil)!
        
        if let networkError = F4SNetworkError(response: httpResponse, attempting: "test") {
            let result = F4SNetworkResult<F4SPlacementJson>.error(networkError)
            return MockF4SPlacementApplicationService(createResult: result)
        } else {
            let result = F4SNetworkResult.success(successJson!)
            return MockF4SPlacementApplicationService(createResult: result)
        }
    }
}

public class MockF4SGetAllPlacementsServiceProtocol: F4SGetAllPlacementsServiceProtocol {
    public init() {}
    public func getAllPlacementsForUser(completion: @escaping (F4SNetworkResult<[F4STimelinePlacement]>) -> ()) {
        
    }
}

public class MockF4STemplateService : F4STemplateServiceProtocol {
    public init() {}
    public func getTemplates(completion: @escaping (F4SNetworkResult<[F4STemplate]>) -> Void) {
        
    }
}

public class MockF4SPlacementService : F4SPlacementApplicationServiceProtocol {
    public init() {}
    
    public func apply(with json: F4SCreatePlacementJson, completion: @escaping (F4SNetworkResult<F4SPlacementJson>) -> Void) {
        
    }
    
    public func update(uuid: F4SUUID, with json: F4SPlacementJson, completion: @escaping (F4SNetworkResult<F4SPlacementJson>) -> Void) {
        
    }
}

public class MockPlacementsRepository: F4SPlacementRepositoryProtocol {
    var placements = [F4SUUID:F4SPlacement]()
    public init() {}
    public func load() -> [F4SPlacement] {
        return Array(placements.values)
    }
    public func save(placement: F4SPlacement) {
        placements[placement.placementUuid!] = placement
    }
}

public class MockInterestsRepository: F4SInterestsRepositoryProtocol {
    var allInterests = [F4SUUID: F4SInterest]()
    var userInterests = [F4SInterest]()
    
    public init() {}
    public func loadAllInterests() -> [F4SInterest] {
        return Array(allInterests.values)
    }
    
    public func loadUserInterests() -> [F4SInterest] {
        return userInterests
    }
}

public class MockF4SUserService: F4SUserServiceProtocol {
    public func registerDeviceWithServer(installationUuid: F4SUUID, completion: @escaping (F4SNetworkResult<F4SRegisterDeviceResult>) -> ()) {
        registerDeviceOnServerCalled += 1
        let result: F4SNetworkResult<F4SRegisterDeviceResult>
        if registerDeviceOnServerCalled == registeringWillSucceedOnAttempt {
            result = F4SNetworkResult.success(successRegisterResult)
        } else {
            result = F4SNetworkResult.error(error)
        }
        completion(result)
    }
    
    
    var registerDeviceOnServerCalled: Int = 0
    var registeringWillSucceedOnAttempt: Int = 0
    var successRegisterResult = F4SRegisterDeviceResult(userUuid: UUID().uuidString)
    var errorResult = F4SRegisterDeviceResult(errors: F4SJSONValue(integerLiteral: 999))
    var error = F4SNetworkError(localizedDescription: "Error handling test", attempting: "test", retry: false, logError: false)
    
    public init(registeringWillSucceedOnAttempt: Int) {
        self.registeringWillSucceedOnAttempt = registeringWillSucceedOnAttempt
    }
    
    public func enablePushNotificationForUser(installationUuid: F4SUUID, withDeviceToken: String, completion: @escaping (F4SNetworkResult<F4SPushNotificationStatus>) -> ()) {
        
    }
    
    public func updateUser(user: F4SUser, completion: @escaping (F4SNetworkResult<F4SUserModel>) -> ()) {
        fatalError()
    }
    
    func enablePushNotificationForUser(withDeviceToken: String, completion: @escaping (F4SNetworkResult<F4SPushNotificationStatus>) -> ()) {
        fatalError()
    }
    
}

public class MockF4SUserStatusService : F4SUserStatusServiceProtocol {
    public var userStatus: F4SUserStatus?
    
    public init() {}
    
    public func beginStatusUpdate() {}
    
    public func getUserStatus(completion: @escaping (F4SNetworkResult<F4SUserStatus>) -> ()) {
        let status = F4SUserStatus(unreadMessageCount: 1, unratedPlacements: [])
        let result = F4SNetworkResult.success(status)
        completion(result)
    }
}




