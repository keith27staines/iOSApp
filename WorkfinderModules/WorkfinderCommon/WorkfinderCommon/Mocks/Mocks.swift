
import Foundation

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
    public func getContent(completion: @escaping (F4SNetworkResult<[F4SContentDescriptor]>) -> ()) {
        
    }
}

public class MockF4SDeviceRegistrationServiceProtocol : F4SDeviceRegistrationServiceProtocol {
    public func registerDevice(anonymousUser: F4SAnonymousUser, completion: @escaping ((F4SNetworkResult<F4SRegisterDeviceResult>) -> ())) {
        
    }
}

public class MockF4SPlacementServiceFactory : F4SPlacementApplicationServiceFactoryProtocol {
    var successJson: F4SPlacementJson?
    let responseStatusCode: HTTPStatusCode
    
    init(successCreatePlacementJson: F4SPlacementJson) {
        self.successJson = successCreatePlacementJson
        self.responseStatusCode = 200
    }
    
    init(errorResponseCode: HTTPStatusCode) {
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
    public func getAllPlacementsForUser(completion: @escaping (F4SNetworkResult<[F4STimelinePlacement]>) -> ()) {
        
    }
}

public class MockF4STemplateService : F4STemplateServiceProtocol {
    public func getTemplates(completion: @escaping (F4SNetworkResult<[F4STemplate]>) -> Void) {
        
    }
}

public class MockF4SPlacementService : F4SPlacementApplicationServiceProtocol {
    public func apply(with json: F4SCreatePlacementJson, completion: @escaping (F4SNetworkResult<F4SPlacementJson>) -> Void) {
        
    }
    
    public func update(uuid: F4SUUID, with json: F4SPlacementJson, completion: @escaping (F4SNetworkResult<F4SPlacementJson>) -> Void) {
        
    }
}

public class MockPlacementsRepository: F4SPlacementRepositoryProtocol {
    var placements = [F4SUUID:F4SPlacement]()
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
    
    init(registeringWillSucceedOnAttempt: Int) {
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
    
    public func beginStatusUpdate() {}
    
    public func getUserStatus(completion: @escaping (F4SNetworkResult<F4SUserStatus>) -> ()) {
        let status = F4SUserStatus(unreadMessageCount: 1, unratedPlacements: [])
        let result = F4SNetworkResult.success(status)
        completion(result)
    }
}




