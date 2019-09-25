//
//  ApplyCoordinatorTests.swift
//  f4s-workexperienceTests
//
//  Created by Keith Dev on 14/03/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import XCTest
import WorkfinderCommon
import WorkfinderNetworking
import WorkfinderServices
import WorkfinderAppLogic
import WorkfinderCoordinators

@testable import WorkfinderApplyUseCase

class ApplyCoordinatorTests: XCTestCase {
    
    let mockRouter = MockNavigationRouter()
    let mockRegisteredUser = F4SUser(uuid: "userUuid1234")
    let mockUnregisteredUser = F4SUser()
    let mockUserService = MockUserService(registeringWillSucceedOnAttempt: 1)
    let mockUserStatusService = MockUserStatusService()
    let mockDatabaseDownloadManager = MockDatabaseDownloadManager()
    let mockAnalytics = MockF4SAnalyticsAndDebugging()
    var mockPlacementServiceFactory = MockPlacementServiceFactory(errorResponseCode: 404)
    
    func makeMockAppInstallationLogic(
        installationUuid: String?,
        user: F4SUser,
        isRegistered: Bool) -> AppInstallationUuidLogic {
        let localStore = MockLocalStore()
        let userRepo = MockUserRepository(user: user)
        localStore.setValue("installationUuid", for: LocalStore.Key.installationUuid)
        localStore.setValue(isRegistered, for: LocalStore.Key.isDeviceRegistered)
        let logic = AppInstallationUuidLogic(localStore: localStore, userService: mockUserService, userRepo: userRepo, apnsEnvironment: "apnsEnvironment")
        return logic
    }
    
    lazy var mockedInjection: CoreInjection = {
        let injection = CoreInjection(
            launchOptions: nil,
            appInstallationUuidLogic: makeMockAppInstallationLogic(installationUuid: "installationUuid", user: mockRegisteredUser, isRegistered: true),
            user: mockRegisteredUser,
            userService: mockUserService,
            userRepository: MockUserRepository(user: mockRegisteredUser),
            databaseDownloadManager: mockDatabaseDownloadManager,
            log: mockAnalytics
        )
        return injection
    }()

    func testStart_withoutPlacement() {
        let sut = makeSUTApplyCoordinator(company: "company1234", continueExistingApplication: nil)
        sut.start()
        XCTAssertEqual(mockRouter.pushedViewControllers.count,1)
        XCTAssertTrue(mockRouter.pushedViewControllers.first! is ApplicationLetterViewController)
    }
    
    func testStart_withPlacement() {
        let sut = makeSUTApplyCoordinator(company: "company1234", continueExistingApplication: "placementUuid")
        sut.start()
        XCTAssertEqual(mockRouter.pushedViewControllers.count,1)
        XCTAssertTrue(mockRouter.pushedViewControllers.first! is ApplicationLetterViewController)
    }

}

extension ApplyCoordinatorTests {
    
    func makeSUTApplyCoordinator(company: F4SUUID, continueExistingApplication uuid: F4SUUID? = nil) -> ApplyCoordinator {
        let now = Date()
        let company = Company(id: 1, created: now, modified: now, isAvailableForSearch: true, uuid: "companyUuid", name: "Test Company", logoUrl: "logoUrl", industry: "Test Industry", latitude: 51, longitude: 0, summary: "This is a test company", employeeCount: 7, turnover: 3, turnoverGrowth: 3, rating: 0, ratingCount: 0, sourceId: "some unknown source", hashtag: "", companyUrl: "companyUrl")
        let placementServiceFactory = MockPlacementServiceFactory(errorResponseCode: 404)
        let mockPlacementService = placementServiceFactory.makePlacementService()
        let mockTemplateService = MockTemplateService()
        let mockPlacementRepository = MockPlacementsRepository()
        let mockInterestsRepository = MockInterestsRepository()
        let sut = ApplyCoordinator(
            company: company,
            parent: nil,
            navigationRouter: mockRouter,
            inject: mockedInjection,
            placementService: mockPlacementService,
            templateService: mockTemplateService,
            placementRepository: mockPlacementRepository,
            interestsRepository: mockInterestsRepository)
        return sut
    }
    
    func makePlacementJsonForCompany(
        company: CompanyViewData,
        userUuid: F4SUUID = "user1",
        placementUuid: F4SUUID = "placement1",
        workflowState: F4SPlacementState = .draft,
        interests: [F4SUUID] = []) -> F4SPlacementJson {
        var placement = F4SPlacementJson(uuid: "1", user: userUuid, company: company.uuid, vendor: "vendorId", interests: interests)
        placement.companyUuid = company.uuid
        placement.userUuid = userUuid
        placement.uuid = placementUuid
        placement.workflowState = workflowState
        placement.interests = interests
        return placement
    }
    
    func makeCompanyViewData() -> CompanyViewData {
        let companyViewData = CompanyViewData()
        return companyViewData
    }
    
}

class MockPlacementServiceFactory : F4SPlacementApplicationServiceFactoryProtocol {
    var successJson: F4SPlacementJson?
    let responseStatusCode: HTTPStatusCode
    
    init(successCreatePlacementJson: F4SPlacementJson) {
        self.successJson = successCreatePlacementJson
        self.responseStatusCode = 200
    }
    
    init(errorResponseCode: HTTPStatusCode) {
        self.responseStatusCode = errorResponseCode
    }
    
    func makePlacementService() -> F4SPlacementApplicationServiceProtocol {
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

class MockTemplateService : F4STemplateServiceProtocol {
    func getTemplates(completion: @escaping (F4SNetworkResult<[F4STemplate]>) -> Void) {
        
    }
}

class MockPlacementService : F4SPlacementApplicationServiceProtocol {
    func apply(with json: F4SCreatePlacementJson, completion: @escaping (F4SNetworkResult<F4SPlacementJson>) -> Void) {
        
    }
    
    func update(uuid: F4SUUID, with json: F4SPlacementJson, completion: @escaping (F4SNetworkResult<F4SPlacementJson>) -> Void) {
        
    }
}

class MockPlacementsRepository: F4SPlacementRepositoryProtocol {
    var placements = [F4SUUID:F4SPlacement]()
    func load() -> [F4SPlacement] {
        return Array(placements.values)
    }
    func save(placement: F4SPlacement) {
        placements[placement.placementUuid!] = placement
    }
}

class MockInterestsRepository: F4SInterestsRepositoryProtocol {
    var allInterests = [F4SUUID: F4SInterest]()
    var userInterests = [F4SInterest]()
    
    func loadAllInterests() -> [F4SInterest] {
        return Array(allInterests.values)
    }
    
    func loadUserInterests() -> [F4SInterest] {
        return userInterests
    }
}

class MockNavigationRouter : NavigationRoutingProtocol {
    func pop(animated: Bool) {
        
    }
    
    func popToViewController(_ viewController: UIViewController, animated: Bool) {
        
    }
    
    
    var navigationController: UINavigationController = UINavigationController()
    
    func push(viewController: UIViewController, animated: Bool = false) {
        pushedViewControllers.append(viewController)
    }
    
    func present(_ viewController: UIViewController, animated: Bool = false, completion: (() -> Void)? = nil) {
        presentedViewControllers.append(viewController)
    }
    
    func dismiss(animated: Bool, completion: (() -> Void)? = nil) {
        guard presentedViewControllers.count > 0 else { return }
        presentedViewControllers.removeLast()
    }
    
    var rootViewController: UIViewController = UIViewController()
    var pushedViewControllers = [UIViewController]()
    var presentedViewControllers = [UIViewController]()
    var dismissCount: Int = 0
    
    func pop() {
        pushedViewControllers.removeLast()
    }
}

class MockUserService: F4SUserServiceProtocol {
    func registerDeviceWithServer(installationUuid: F4SUUID, completion: @escaping (F4SNetworkResult<F4SRegisterDeviceResult>) -> ()) {
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
    
    func enablePushNotificationForUser(installationUuid: F4SUUID, withDeviceToken: String, completion: @escaping (F4SNetworkResult<F4SPushNotificationStatus>) -> ()) {
        
    }
    
    func updateUser(user: F4SUser, completion: @escaping (F4SNetworkResult<F4SUserModel>) -> ()) {
        fatalError()
    }
    
    func enablePushNotificationForUser(withDeviceToken: String, completion: @escaping (F4SNetworkResult<F4SPushNotificationStatus>) -> ()) {
        fatalError()
    }
    
}

class MockUserStatusService : F4SUserStatusServiceProtocol {
    var userStatus: F4SUserStatus?
    
    func beginStatusUpdate() {}
    
    func getUserStatus(completion: @escaping (F4SNetworkResult<F4SUserStatus>) -> ()) {
        let status = F4SUserStatus(unreadMessageCount: 1, unratedPlacements: [])
        let result = F4SNetworkResult.success(status)
        completion(result)
    }
}

class MockF4SAnalyticsAndDebugging : F4SAnalyticsAndDebugging {
    
    var identities: [F4SUUID] = []
    var aliases: [F4SUUID] = []
    
    func identity(userId: F4SUUID) {
        identities.append(userId)
    }
    
    func alias(userId: F4SUUID) {
        aliases.append(userId)
    }
    
    var notifiedErrors = [Error]()
    
    func notifyError(_ error: NSError, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        notifiedErrors.append(error)
    }
    
    var breadcrumbs = [String]()
    func leaveBreadcrumb(with message: String, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        breadcrumbs.append(message)
    }
    
    var updateHistoryCallCount: Int = 0
    func updateHistory() {
        updateHistoryCallCount += 1
    }
    
    var textCombiningHistoryAndSessionLogCallCount: Int = 0
    func textCombiningHistoryAndSessionLog() -> String? {
        textCombiningHistoryAndSessionLogCallCount += 1
        return ""
    }
    
    var _userCanAccessDebugMenu: Bool = false
    func userCanAccessDebugMenu() -> Bool {
        return _userCanAccessDebugMenu
    }
    
    var loggedErrorMessages = [String]()
    func error(message: String, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        loggedErrorMessages.append(message)
    }
    
    var loggedErrors = [Error]()
    func error(_ error: Error, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        loggedErrors.append(error)
    }
    
    var debugMessages = [String]()
    func debug(_ message: String, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        debugMessages.append(message)
    }
}

class MockDatabaseDownloadManager : F4SDatabaseDownloadManagerProtocol {
    
    // spies
    var registeredObservers = [F4SCompanyDatabaseAvailabilityObserving]()
    
    var age: TimeInterval = 0
    var isAvailable: Bool = false
    
    // interface
    var localDatabaseDatestamp: Date?
    
    func registerObserver(_ observer: F4SCompanyDatabaseAvailabilityObserving) {
        registeredObservers.append(observer)
    }
    
    func removeObserver(_ observer: F4SCompanyDatabaseAvailabilityObserving) {
        registeredObservers.removeAll { (anObserver) -> Bool in
            anObserver === observer
        }
    }
    
    func ageOfLocalDatabase() -> TimeInterval {
        return age
    }
    
    func isLocalDatabaseAvailable() -> Bool {
        return isAvailable
    }
    
    func start() {}
}
