//
//  F4SUserTests.swift
//  f4s-workexperienceTests
//
//  Created by Keith Dev on 20/02/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import XCTest

@testable import WorkfinderCommon

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
        let sut = makeUser(injectingLocalStore: injectedStore, analytics: mockAnalytics)
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
    
    func makeUser(injectingLocalStore: LocalStorageProtocol, analytics: F4SAnalytics? = nil) -> F4SUser {
        let user = F4SUser(localStore: injectingLocalStore)
        user.analytics = analytics ?? MockF4SAnalyticsAndDebugging()
        return user
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
    
    func notifyError(_ error: Error, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
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
