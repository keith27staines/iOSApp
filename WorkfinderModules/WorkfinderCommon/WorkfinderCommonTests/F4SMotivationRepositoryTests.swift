//
//  F4SMotivationRepositoryTests.swift
//  WorkfinderCommonTests
//
//  Created by Keith Dev on 04/02/2020.
//  Copyright © 2020 Founders4Schools. All rights reserved.
//

import XCTest
@testable import WorkfinderCommon

class F4SMotivationRepositoryTests: XCTestCase {
    
    let store = MockLocalStore()
    
    func makeSUT() -> F4SMotivationRepository {
        return F4SMotivationRepository(localStore: store)
    }
    
    func test_initialise_with_store() {
        store.setValue("test value", for: LocalStore.Key.motivationKey)
        let sut = F4SMotivationRepository(localStore: store)
        XCTAssertEqual(sut.localStore.value(key: LocalStore.Key.motivationKey) as! String, "test value")
    }
    
    func test_loadMotivationType_when_standard() {
        let sut = makeSUT()
        sut.localStore.setValue(true, for: LocalStore.Key.useDefaultMotivation)
        XCTAssertEqual(sut.loadMotivationType(), .standard)
    }

    func test_loadMotivationType_when_custom() {
        let sut = makeSUT()
        sut.localStore.setValue(false, for: LocalStore.Key.useDefaultMotivation)
        XCTAssertEqual(sut.loadMotivationType(), .custom)
    }

    func test_loadMotivationType_when_not_previously_defined() {
        let sut = makeSUT()
        XCTAssertEqual(sut.loadMotivationType(), .standard)
    }
    
    func test_loadDefaultMotivation() {
        let sut = makeSUT()
        XCTAssertTrue(sut.loadDefaultMotivation().count > 0)
    }
    
    func test_loadCustomMotivation() {
        let sut = makeSUT()
        sut.localStore.setValue("custom motivation", for: LocalStore.Key.motivationKey)
        XCTAssertTrue(sut.loadCustomMotivation() == "custom motivation")
    }
    
    func test_save_custom_motivation() {
        let sut = makeSUT()
        sut.saveCustomMotivation("custom motivation")
        XCTAssertTrue(sut.loadCustomMotivation() == "custom motivation")
    }
    
    func test_saveMotivationType() {
        let sut = makeSUT()
        sut.saveMotivationType(.custom)
        XCTAssertEqual(sut.loadMotivationType(), .custom)
    }

}
