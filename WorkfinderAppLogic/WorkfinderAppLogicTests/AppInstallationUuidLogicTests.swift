//
//  AppInstallationUuidLogicTests.swift
//  f4s-workexperienceTests
//
//  Created by Keith Dev on 20/07/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import XCTest
import WorkfinderCommon
import WorkfinderNetworking
import WorkfinderServices
@testable import WorkfinderAppLogic

class AppInstallationUuidLogicTests: XCTestCase {

    func test_ensure_SUT_uses_injected_store() {
        let localStore = MockLocalStore()
        localStore.setValue("1234567890", for: LocalStore.Key.invokingUrl)
        let sut = makeSUT(localStore: localStore)
        XCTAssertEqual(
            sut.localStore.value(key: LocalStore.Key.invokingUrl) as! String,
            localStore.value(key: LocalStore.Key.invokingUrl)  as! String
        )
    }
    
    func test_installationUuid_on_first_install() {
        let sut = makeSUT()
        XCTAssert(sut.installationUuid == nil)
    }
    
    func test_registeredUuid_on_first_install() {
        let sut = makeSUT()
        XCTAssert(sut.registeredInstallationUuid == nil)
    }
    
    func test_makeInstallationUuid() {
        let sut = makeSUT()
        let uuid = sut.makeNewInstallationUuid()
        XCTAssertEqual(sut.installationUuid, uuid)
        XCTAssertNil(sut.registeredInstallationUuid)
    }
    
    func makeSUT(localStore: LocalStorageProtocol = MockLocalStore()) -> AppInstallationUuidLogic {
        let user = F4SUser(uuid: "uuid")
        let userRepo = MockUserRepository(user: user)
        let userService = MockUserService(registeringWillSucceedOnAttempt: 1)
        let registrationService = MockDeviceRegistationService()
        return AppInstallationUuidLogic(
            localStore: localStore,
            userService: userService,
            userRepo: userRepo,
            apnsEnvironment: "apnsEnvironment",
            registerDeviceService: registrationService)
    }
    
}

class MockDeviceRegistationService: F4SDeviceRegistrationServiceProtocol {
    func registerDevice(anonymousUser: F4SAnonymousUser, completion: @escaping ((F4SNetworkResult<F4SRegisterDeviceResult>) -> ())) {
        
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
