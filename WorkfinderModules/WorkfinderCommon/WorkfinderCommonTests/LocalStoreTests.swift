//
//  LocalStoreTests.swift
//  WorkfinderCommonTests
//
//  Created by Keith Dev on 13/08/2019.
//  Copyright © 2019 Workfinder Ltd. All rights reserved.
//

import XCTest
@testable import WorkfinderCommon

class LocalStoreTests: XCTestCase {
    var testUserDefaults: UserDefaults!
    var defaultsName = "WorkfinderCommon.LocalStoreTests"
    
    override func setUp() {
        defaultsName = UUID().uuidString
        testUserDefaults = UserDefaults(suiteName: defaultsName)
    }
    
    override func tearDown() {
        UserDefaults.standard.removeSuite(named: defaultsName)
        UserDefaults.standard.removePersistentDomain(forName: defaultsName)
        testUserDefaults.removeSuite(named: defaultsName)
    }


    func test_initialise_with_defauls() {
        let sut = LocalStore()
        XCTAssertTrue(sut.userDefaults === UserDefaults.standard)
    }
    
    func test_initialise_with_specified_suite() {
        let sut = LocalStore(userDefaults: testUserDefaults)
        XCTAssertTrue(sut.userDefaults === testUserDefaults)
    }
    
    func test_setValue() {
        let sut = LocalStore(userDefaults: testUserDefaults)
        XCTAssertNil(sut.value(key: LocalStore.Key.installationUuid))
        sut.setValue("1234", for: LocalStore.Key.installationUuid)
        XCTAssertEqual(sut.value(key: LocalStore.Key.installationUuid) as! String, "1234")
    
    }
    
    func test_userDefaults_extension() {
        XCTAssertNil(testUserDefaults.value(key: .installationUuid))
        testUserDefaults.setValue("12345", for: LocalStore.Key.installationUuid)
        XCTAssertEqual(testUserDefaults.value(key: LocalStore.Key.installationUuid) as! String, "12345")
    }

}
