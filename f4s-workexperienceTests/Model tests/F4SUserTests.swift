//
//  F4SUserTests.swift
//  f4s-workexperienceTests
//
//  Created by Keith Dev on 20/02/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import XCTest

@testable import f4s_workexperience

class F4SUserTests: XCTestCase {

    func testCreateUserWithDefaultStorage() {
        XCTAssertTrue(F4SUser().localStore === UserDefaults.standard)
    }
    
    func testCreateUserWithInjectedStorage() {
        let injectedStore = makeMockLocalStore()
        let sut = makeUser(injectingLocalStore: injectedStore)
        XCTAssertTrue(sut.localStore === injectedStore)
    }
    
    func testCreateUserWithNoUuid() {
        let injectedStore = makeMockLocalStore(userUuid: nil)
        let sut = makeUser(injectingLocalStore: injectedStore)
        XCTAssertNil(sut.uuid)
    }
    
    func testCreateUserWithUuid() {
        let injectedStore = makeMockLocalStore(userUuid: "userUuid")
        let sut = makeUser(injectingLocalStore: injectedStore)
        XCTAssertEqual(sut.uuid,"userUuid")
    }
    
    func testAnalyticsInjection() {
        let injectedStore = makeMockLocalStore(userUuid: "userUuid")
        let mockAnalytics = MockF4SAnalyticsAndDebugging()
        let sut = makeUser(injectingLocalStore: injectedStore, analytics: mockAnalytics)
        let sutAnalytics = sut.analytics as! MockF4SAnalyticsAndDebugging
        XCTAssertTrue(sutAnalytics === mockAnalytics)
        XCTAssertEqual(sutAnalytics.aliases.count, 0)
    }
    
    func testAnalyticsAliasCalledOnUpdatingUserUuid() {
        let injectedStore = makeMockLocalStore(userUuid: "userUuid")
        let mockAnalytics = MockF4SAnalyticsAndDebugging()
        var sut = makeUser(injectingLocalStore: injectedStore, analytics: mockAnalytics)
        sut.updateUuid(uuid: "otherUuid")
        XCTAssertTrue(mockAnalytics.aliases.first == "otherUuid")
        XCTAssertTrue(mockAnalytics.aliases.count == 1)
    }
    
    func testNonOnboardedUser() {
        let injectedStore = makeMockLocalStore(userUuid: "uuid", isOnboarded: false)
        let sut = makeUser(injectingLocalStore: injectedStore)
        XCTAssertEqual(sut.isOnboarded, false)
    }
    
    func testUserWithNoDictionaryEntryForIsFirstLaunch() {
        let injectedStore = makeMockLocalStore(userUuid: "uuid", isOnboarded: false)
        injectedStore.setValue(nil, for: LocalStore.Key.isFirstLaunch)
        let sut = makeUser(injectingLocalStore: injectedStore)
        XCTAssertEqual(sut.isOnboarded, false)
    }
    
    func testUserDidOnboard() {
        let injectedStore = makeMockLocalStore(userUuid: "uuid", isOnboarded: false)
        let sut = makeUser(injectingLocalStore: injectedStore)
        sut.didFinishOnboarding()
        XCTAssertEqual(sut.isOnboarded, true)
    }
    
    func makeMockLocalStore(userUuid: F4SUUID? = nil, isOnboarded: Bool = false) -> MockLocalStore {
        let injectedStore = MockLocalStore()
        injectedStore.setValue(userUuid, for: LocalStore.Key.userUuid)
        injectedStore.setValue(!isOnboarded, for: LocalStore.Key.isFirstLaunch)
        return injectedStore
    }
    
    func makeUser(injectingLocalStore: LocalKeyedStorage, analytics: F4SAnalytics? = nil) -> F4SUser {
        var user = F4SUser(localStore: injectingLocalStore)
        user.analytics = analytics ?? MockF4SAnalyticsAndDebugging()
        return user
    }
}

class MockLocalStore : LocalKeyedStorage {
    
    var store: [LocalStore.Key: Any] = [:]
    
    func value(key: LocalStore.Key) -> Any? {
        let value = store[key]
        return value
    }
    
    func setValue(_ value: Any?, for key: LocalStore.Key) {
        store[key] = value
    }
}
