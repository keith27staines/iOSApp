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
    
    func testCreateUserWithNoUuid() {
        let sut = F4SUser()
        XCTAssertNil(sut.uuid)
        XCTAssertEqual(sut.email, "")
        XCTAssertEqual(sut.firstName, "")
        XCTAssertNil(sut.lastName)
        XCTAssertNil(sut.consenterEmail)
        XCTAssertNil(sut.parentEmail)
        XCTAssertFalse(sut.requiresConsent)
        XCTAssertNil(sut.dateOfBirth)
        XCTAssertNil(sut.partners)
        XCTAssertFalse(sut.termsAgreed)
        XCTAssertNil(sut.fullName)
    }
    
    func testCreateUserWithUuid() {
        let date = Date()
        let sut = F4SUser(uuid: "uuid", email: "email", firstName: "first", lastName: "last", consenterEmail: "consenter", parentEmail: "parent", requiresConsent: true, dateOfBirth: date, partners: [], termsAgreed: true)
        XCTAssertEqual(sut.uuid, "uuid")
        XCTAssertEqual(sut.email, "email")
        XCTAssertEqual(sut.firstName, "first")
        XCTAssertEqual(sut.lastName, "last")
        XCTAssertEqual(sut.consenterEmail, "consenter")
        XCTAssertEqual(sut.parentEmail, "parent")
        XCTAssertEqual(sut.requiresConsent, true)
        XCTAssertEqual(sut.dateOfBirth, date)
        XCTAssertEqual(sut.partners!.count, 0)
        XCTAssertEqual(sut.termsAgreed, true)
        XCTAssertEqual(sut.fullName, "first last")
    }
    
    func test_user_fullName_with_first_and_last_names() {
        var sut = F4SUser()
        sut.firstName = "first"
        sut.lastName = "last"
        XCTAssertTrue(sut.fullName == "first last")
    }
    
    func test_user_fullName_with_first_name_only() {
        var sut = F4SUser()
        sut.firstName = "first"
        XCTAssertTrue(sut.fullName == "first")
    }
    
    func test_user_fullName_with_last_name_only() {
        var sut = F4SUser()
        sut.lastName = "last"
        XCTAssertTrue(sut.fullName == "last")
    }
    
    func test_user_fullName_with_first_and_compound_last_name() {
        var sut = F4SUser()
        sut.firstName = "first"
        sut.lastName = "middle last"
        XCTAssertTrue(sut.fullName == "first middle last")
    }
    
    func test_age_zero() {
        var sut = F4SUser()
        sut.dateOfBirth = DateComponents(calendar: Calendar.current, year: 2000, month: 1, day: 1).date
        let testDate = DateComponents(calendar: Calendar.current, year: 2000, month: 1, day: 1).date
        let age = sut.age(on: testDate!)
        XCTAssertTrue(age == 0)
    }
    
    func test_age_99() {
        var sut = F4SUser()
        sut.dateOfBirth = DateComponents(calendar: Calendar.current, year: 2000, month: 1, day: 1).date
        let testDate = DateComponents(calendar: Calendar.current, year: 2099, month: 1, day: 1).date
        let age = sut.age(on: testDate!)
        XCTAssertTrue(age == 99)
    }
    
    func test_age_day_before_birthday() {
        var sut = F4SUser()
        sut.dateOfBirth = DateComponents(calendar: Calendar.current, year: 2000, month: 6, day: 15).date
        let testDate = DateComponents(calendar: Calendar.current, year: 2016, month: 6, day: 14).date
        let age = sut.age(on: testDate!)
        XCTAssertTrue(age == 15)
    }
    
    func test_age_on_birthday() {
        var sut = F4SUser()
        sut.dateOfBirth = DateComponents(calendar: Calendar.current, year: 2000, month: 6, day: 15).date
        let testDate = DateComponents(calendar: Calendar.current, year: 2016, month: 6, day: 15).date
        let age = sut.age(on: testDate!)
        XCTAssertTrue(age == 16)
    }
    
    func test_age_one_day_after_birthday() {
        var sut = F4SUser()
        sut.dateOfBirth = DateComponents(calendar: Calendar.current, year: 2000, month: 6, day: 15).date
        let testDate = DateComponents(calendar: Calendar.current, year: 2016, month: 6, day: 16).date
        let age = sut.age(on: testDate!)
        XCTAssertTrue(age == 16)
    }
    
    func test_age_before_dob_set() {
        let sut = F4SUser()
        let testDate = DateComponents(calendar: Calendar.current, year: 2016, month: 6, day: 16).date
        let age = sut.age(on: testDate!)
        XCTAssertNil(age)
    }
    
    func test_initialise_with_user_data() {
        let userData = TestUserData(userUuid: "uuid", email: "email", firstName: "firstName", lastName: "lastName", consenterEmail: "consenter", requiresConsent: true, dateOfBirth: "2000-01-01")
        let sut = F4SUser(userData: userData, localStore: MockLocalStore())
        XCTAssertEqual(sut.uuid, "uuid")
        XCTAssertEqual(sut.email, "email")
        XCTAssertEqual(sut.firstName, "firstName")
        XCTAssertEqual(sut.lastName, "lastName")
        XCTAssertEqual(sut.consenterEmail, "consenter")
        XCTAssertEqual(sut.requiresConsent, true)
        XCTAssertEqual(sut.dateOfBirth, DateComponents(calendar: Calendar.current,year: 2000, month: 1, day: 1).date!)
    }
}

extension F4SUserTests {
    func assertUserInfoEquivalent(info1: F4SUser, info2: F4SUser) {
        XCTAssertTrue(
            info1.consenterEmail == info1.consenterEmail &&
                info1.dateOfBirth == info1.dateOfBirth &&
                info1.email == info1.email &&
                info1.firstName == info1.firstName &&
                info1.lastName == info1.lastName &&
                info1.parentEmail == info1.parentEmail &&
                info1.partners!.first!.uuid == info1.partners!.first!.uuid &&
                info1.requiresConsent == info1.requiresConsent &&
                info1.termsAgreed == info1.termsAgreed &&
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
        let user = injectingLocalStore.value(key: LocalStore.Key.user)
        return user as! F4SUser
    }
}

struct TestUserData: UserData {
    var userUuid: String?
    
    var email: String?
    
    var firstName: String?
    
    var lastName: String?
    
    var consenterEmail: String?
    
    var requiresConsent: Bool
    
    var dateOfBirth: String?
    
}
