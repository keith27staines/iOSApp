//
//  AppInstallationLogicTests.swift
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

class AppInstallationLogicTests: XCTestCase {

    func test_ensure_SUT_uses_injected_store() {
        let localStore = MockLocalStore()
        localStore.setValue("1234567890", for: LocalStore.Key.accessToken)
        let sut = makeSUT(localStore: localStore)
        XCTAssertEqual(
            sut.localStore.value(key: LocalStore.Key.accessToken) as! String,
            localStore.value(key: LocalStore.Key.accessToken)  as! String
        )
    }
    
    func makeSUT(localStore: LocalStorageProtocol = MockLocalStore()) -> AppInstallationLogic {
        return AppInstallationLogic(localStore: localStore)
    }
    
}
