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
    var breadcrumbs = [String]()
    var updateHistoryCallCount: Int = 0
    var textCombiningHistoryAndSessionLogCallCount: Int = 0
    var _userCanAccessDebugMenu: Bool = false
    var loggedErrorMessages = [String]()
    var loggedErrors = [Error]()
    var debugMessages = [String]()
    var notifiedErrors = [Error]()
    
    func identity(userId: F4SUUID) {
        identities.append(userId)
    }
    
    func alias(userId: F4SUUID) {
        aliases.append(userId)
    }
    
    func notifyError(_ error: Error, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        notifiedErrors.append(error)
    }
    
    func notifyError(_ error: NSError, functionName: StaticString, fileName: StaticString, lineNumber: Int) {
        notifiedErrors.append(error)
    }
    
    
    func leaveBreadcrumb(with message: String, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        breadcrumbs.append(message)
    }
    
    func updateHistory() {
        updateHistoryCallCount += 1
    }
    
    func textCombiningHistoryAndSessionLog() -> String? {
        textCombiningHistoryAndSessionLogCallCount += 1
        return ""
    }
    
    func userCanAccessDebugMenu() -> Bool {
        return _userCanAccessDebugMenu
    }
    
    func error(message: String, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        loggedErrorMessages.append(message)
    }
    
    func error(_ error: Error, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        loggedErrors.append(error)
    }
    
    func debug(_ message: String, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        debugMessages.append(message)
    }
}
