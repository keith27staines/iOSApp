
import Foundation

public class MockF4SRoleService: F4SRoleServiceProtocol {
    public func getRoleForCompany(companyUuid: F4SUUID, roleUuid: F4SUUID, completion: @escaping (F4SNetworkResult<F4SRoleJson>) -> ()) {
        
    }
    
    public init() {}
}

public class MockF4SRecommendationService: F4SRecommendationServiceProtocol {
    public func fetch(completion: @escaping (F4SNetworkResult<[F4SRecommendation]>) -> ()) {
        
    }
    
    public init() {}
}

public class MockOnboardingCoordinatorFactory: OnboardingCoordinatorFactoryProtocol {
    
    public var onboardingCoordinators = [MockOnboardingCoordinator]()
    
    public func makeOnboardingCoordinator(
        parent: Coordinating?,
        navigationRouter: NavigationRoutingProtocol) -> OnboardingCoordinatorProtocol {
        let coordinator = MockOnboardingCoordinator(parent: parent)
        onboardingCoordinators.append(coordinator)
        return coordinator
    }
    
    public init() {}
}

public class MockF4SCompanyRepository: F4SCompanyRepositoryProtocol {
    var counter: Int = 0
    var companies = [F4SUUID: F4SCompanyJson]()
    
    public func load(companyUuids: [F4SUUID], completion: @escaping (([F4SCompanyJson]) -> Void)) {
        let companies = companyUuids.map { (uuid) -> F4SCompanyJson in
            return self.getCompany(uuid: uuid)
        }
        completion(companies)
    }
    
    private func getCompany(uuid: F4SUUID) -> F4SCompanyJson {
        if let company = companies[uuid] { return company }
        let company = makeCompany(uuid: uuid)
        companies[uuid] = company
        return company
    }
    
    func makeRandomName() -> String {
        let length = Int.random(in: 2...100)
        let type = Bool.random() ? " LTD" : " PLC"
        return randomString(length: length) + type
    }
    
    func randomString(length: Int) -> String {
      let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    func makeCompany(uuid: F4SUUID) -> F4SCompanyJson {
        counter += 1
        return F4SCompanyJson(
            name: makeRandomName(),
            industry: "Making stuff",
            logoUrlString: "url/logo",
            summary: "We make stuff",
            employeeCount: 100,
            turnover: 100.0,
            turnoverGrowth: 10.0,
            duedilUrlString: "duedil/url",
            linkedInUrlString: "linkedIn/url")
    }
    
    public init() {}
}

public class MockCompanyCoordinatorFactory: CompanyCoordinatorFactoryProtocol {
    public init() {}
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
        company: F4SCompanyJson,
        inject: CoreInjectionProtocol) -> CompanyCoordinatorProtocol {
        return MockCompanyCoordinator(
            parent: parent,
            navigationRouter: navigationRouter,
            inject: inject,
            company: company)
    }
}

public class MockCompanyCoordinator: CompanyCoordinatorProtocol {
    public var originScreen: ScreenName = .notSpecified
    public let uuid = UUID()
    public var injected: CoreInjectionProtocol
    public var parentCoordinator: Coordinating?
    public var childCoordinators: [UUID : Coordinating] = [:]
    public var navigationRouter: NavigationRoutingProtocol
    public var company: F4SCompanyJson?
    
    public func start() {
        
    }
    
    public init(parent: CompanyCoordinatorParentProtocol,
                navigationRouter: NavigationRoutingProtocol,
                inject: CoreInjectionProtocol,
                company: F4SCompanyJson) {
        self.parentCoordinator = parent
        self.injected = inject
        self.navigationRouter = navigationRouter
        self.company = company
    }
    
    public init(parent: CompanyCoordinatorParentProtocol,
                navigationRouter: NavigationRoutingProtocol,
                inject: CoreInjectionProtocol,
                companyUuid: F4SUUID) {
        self.parentCoordinator = parent
        self.injected = inject
        self.navigationRouter = navigationRouter
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

public class MockF4STemplateService : F4STemplateServiceProtocol {
    public init() {}
    public func getTemplates(completion: @escaping (F4SNetworkResult<[F4STemplate]>) -> Void) {
        
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




