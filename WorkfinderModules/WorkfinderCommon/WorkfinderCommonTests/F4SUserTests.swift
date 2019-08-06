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
    
    func test_user_fullName_with_first_and_last_names() {
        let injectedStore = makeMockLocalStore(userUuid: "uuid", isOnboarded: false)
        let sut = makeUser(injectingLocalStore: injectedStore)
        sut.firstName = "first"
        sut.lastName = "last"
        XCTAssertTrue(sut.fullName == "first last")
    }
    
    func test_user_fullName_with_first_name_only() {
        let injectedStore = makeMockLocalStore(userUuid: "uuid", isOnboarded: false)
        let sut = makeUser(injectingLocalStore: injectedStore)
        sut.firstName = "first"
        XCTAssertTrue(sut.fullName == "first")
    }
    
    func test_user_fullName_with_last_name_only() {
        let injectedStore = makeMockLocalStore(userUuid: "uuid", isOnboarded: false)
        let sut = makeUser(injectingLocalStore: injectedStore)
        sut.lastName = "last"
        XCTAssertTrue(sut.fullName == "last")
    }
    
    func test_user_fullName_with_first_and_compound_last_name() {
        let injectedStore = makeMockLocalStore(userUuid: "uuid", isOnboarded: false)
        let sut = makeUser(injectingLocalStore: injectedStore)
        sut.firstName = "first"
        sut.lastName = "middle last"
        XCTAssertTrue(sut.fullName == "first middle last")
    }
    
    func test_user_fullName_with_no_name() {
        let injectedStore = makeMockLocalStore(userUuid: "uuid", isOnboarded: false)
        let sut = makeUser(injectingLocalStore: injectedStore)
        XCTAssertNil(sut.fullName)
    }
    
    func test_nillifyUuid() {
        let injectedStore = makeMockLocalStore(userUuid: "uuid", isOnboarded: false)
        let sut = makeUser(injectingLocalStore: injectedStore)
        sut.nullifyUuid()
        XCTAssertNil(sut.uuid)
    }
    
    func test_age_zero() {
        let injectedStore = makeMockLocalStore(userUuid: "uuid", isOnboarded: false)
        let sut = makeUser(injectingLocalStore: injectedStore)
        sut.dateOfBirth = DateComponents(calendar: Calendar.current, year: 2000, month: 1, day: 1).date
        let testDate = DateComponents(calendar: Calendar.current, year: 2000, month: 1, day: 1).date
        let age = sut.age(on: testDate!)
        XCTAssertTrue(age == 0)
    }
    
    func test_age_99() {
        let injectedStore = makeMockLocalStore(userUuid: "uuid", isOnboarded: false)
        let sut = makeUser(injectingLocalStore: injectedStore)
        sut.dateOfBirth = DateComponents(calendar: Calendar.current, year: 2000, month: 1, day: 1).date
        let testDate = DateComponents(calendar: Calendar.current, year: 2099, month: 1, day: 1).date
        let age = sut.age(on: testDate!)
        XCTAssertTrue(age == 99)
    }
    
    func test_age_day_before_birthday() {
        let injectedStore = makeMockLocalStore(userUuid: "uuid", isOnboarded: false)
        let sut = makeUser(injectingLocalStore: injectedStore)
        sut.dateOfBirth = DateComponents(calendar: Calendar.current, year: 2000, month: 6, day: 15).date
        let testDate = DateComponents(calendar: Calendar.current, year: 2016, month: 6, day: 14).date
        let age = sut.age(on: testDate!)
        XCTAssertTrue(age == 15)
    }
    
    func test_age_on_birthday() {
        let injectedStore = makeMockLocalStore(userUuid: "uuid", isOnboarded: false)
        let sut = makeUser(injectingLocalStore: injectedStore)
        sut.dateOfBirth = DateComponents(calendar: Calendar.current, year: 2000, month: 6, day: 15).date
        let testDate = DateComponents(calendar: Calendar.current, year: 2016, month: 6, day: 15).date
        let age = sut.age(on: testDate!)
        XCTAssertTrue(age == 16)
    }
    
    func test_age_one_day_after_birthday() {
        let injectedStore = makeMockLocalStore(userUuid: "uuid", isOnboarded: false)
        let sut = makeUser(injectingLocalStore: injectedStore)
        sut.dateOfBirth = DateComponents(calendar: Calendar.current, year: 2000, month: 6, day: 15).date
        let testDate = DateComponents(calendar: Calendar.current, year: 2016, month: 6, day: 16).date
        let age = sut.age(on: testDate!)
        XCTAssertTrue(age == 16)
    }
    
    func test_age_before_dob_set() {
        let injectedStore = makeMockLocalStore(userUuid: "uuid", isOnboarded: false)
        let sut = makeUser(injectingLocalStore: injectedStore)
        let testDate = DateComponents(calendar: Calendar.current, year: 2016, month: 6, day: 16).date
        let age = sut.age(on: testDate!)
        XCTAssertNil(age)
    }
    
    func test_nullifyUuid() {
        let injectedStore = makeMockLocalStore(userUuid: "uuid", isOnboarded: false)
        let sut = makeUser(injectingLocalStore: injectedStore)
        sut.nullifyUuid()
        XCTAssertNil(sut.uuid)
    }
    
    func test_isOnboarded_when_not_onboarded() {
        let injectedStore = makeMockLocalStore(userUuid: "uuid", isOnboarded: false)
        injectedStore.setValue(nil, for: LocalStore.Key.isFirstLaunch)
        let sut = makeUser(injectingLocalStore: injectedStore)
        XCTAssertFalse(sut.isOnboarded)
    }
    
    func test_isOnboarded_when_onboarded() {
        let injectedStore = makeMockLocalStore(userUuid: "uuid", isOnboarded: false)
        let sut = makeUser(injectingLocalStore: injectedStore)
        sut.didFinishOnboarding()
        XCTAssertTrue(sut.isOnboarded)
    }
    
    func test_initialise_from_user_info() {
        let dob = DateComponents(calendar: Calendar.current, year: 2000, month: 1, day: 1).date!
        let partners = [F4SUUIDDictionary(uuid: "partnerUuid")]
        let info1 = F4SUserInformation(uuid: "uuid", consenterEmail: "consenterEmail", parentEmail: "parentEmail", dateOfBirth: dob, email: "userEmail", firstName: "first", lastName: "last", requiresConsent: false, termsAgreed: false, vouchers: ["voucherUuid"], partners: partners, isOnboarded: false, isRegistered: false)
        let sut = F4SUser(userInformation: info1)
        let info2 = sut.extractUserInformation()
        assertUserInfoEquivalent(info1: info1, info2: info2)
    }
    
    func test_initialise_from_local_store() {
        let dob = DateComponents(calendar: Calendar.current, year: 2000, month: 1, day: 1).date!
        let partners = [F4SUUIDDictionary(uuid: "partnerUuid")]
        let info1 = F4SUserInformation(uuid: "uuid", consenterEmail: "consenterEmail", parentEmail: "parentEmail", dateOfBirth: dob, email: "userEmail", firstName: "first", lastName: "last", requiresConsent: false, termsAgreed: false, vouchers: ["voucherUuid"], partners: partners, isOnboarded: false, isRegistered: false)
        let userToStore = F4SUser(userInformation: info1)
        let localStore = MockLocalStore()
        let repo = F4SUserRepository(localStore: localStore)
        repo.save(user: userToStore)
        let sut = F4SUser(localStore: localStore)
        let info2 = sut.extractUserInformation()
        assertUserInfoEquivalent(info1: info1, info2: info2)
    }
    
    func test_update_from_user_info() {
        let dob = DateComponents(calendar: Calendar.current, year: 2000, month: 1, day: 1).date!
        let partners = [F4SUUIDDictionary(uuid: "partnerUuid")]
        let info = F4SUserInformation(uuid: "uuid", consenterEmail: "consenterEmail", parentEmail: "parentEmail", dateOfBirth: dob, email: "userEmail", firstName: "first", lastName: "last", requiresConsent: false, termsAgreed: false, vouchers: ["voucherUuid"], partners: partners, isOnboarded: false, isRegistered: false)
        
        let dob1 = DateComponents(calendar: Calendar.current, year: 2001, month: 1, day: 1).date!
        let partners1 = [F4SUUIDDictionary(uuid: "partnerUuid1")]
        let updateInfo = F4SUserInformation(uuid: "uuid1", consenterEmail: "consenterEmail1", parentEmail: "parentEmail1", dateOfBirth: dob1, email: "userEmail1", firstName: "first1", lastName: "last1", requiresConsent: true, termsAgreed: true, vouchers: ["voucherUuid1"], partners: partners1, isOnboarded: true, isRegistered: true)
        
        let sut = F4SUser(userInformation: info)
        sut.updateFromUserInformation(updateInfo)
        assertUserInfoEquivalent(info1: updateInfo, info2: sut.extractUserInformation())
    }
}

extension F4SUserTests {
    func assertUserInfoEquivalent(info1: F4SUserInformation, info2: F4SUserInformation) {
        XCTAssertTrue(
            info1.consenterEmail == info1.consenterEmail &&
                info1.dateOfBirth == info1.dateOfBirth &&
                info1.email == info1.email &&
                info1.firstName == info1.firstName &&
                info1.lastName == info1.lastName &&
                info1.isOnboarded == info1.isOnboarded &&
                info1.parentEmail == info1.parentEmail &&
                info1.partners!.first!.uuid == info1.partners!.first!.uuid &&
                info1.requiresConsent == info1.requiresConsent &&
                info1.termsAgreed == info1.termsAgreed &&
                info1.vouchers == info1.vouchers &&
                info1.fullName == info1.fullName
        )
    }
}

extension F4SUserTests {
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
