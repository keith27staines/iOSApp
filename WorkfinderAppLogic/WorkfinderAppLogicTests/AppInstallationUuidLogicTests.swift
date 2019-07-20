//
//  AppInstallationUuidLogicTests.swift
//  f4s-workexperienceTests
//
//  Created by Keith Dev on 20/07/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import XCTest
import WorkfinderCommon
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
    
    func test_on_installationUuid_was_registered() {
        let sut = makeSUT()
        let uuid = sut.makeNewInstallationUuid()
        sut.onInstallationUuidWasRegisteredWithServer(uuid)
        XCTAssertEqual(uuid, sut.installationUuid)
        XCTAssertEqual(uuid, sut.registeredInstallationUuid)
    }
    
    func makeSUT(localStore: LocalStorageProtocol = MockLocalStore()) -> AppInstallationUuidLogic {
        return AppInstallationUuidLogic(localStore: localStore)
    }
    
}
