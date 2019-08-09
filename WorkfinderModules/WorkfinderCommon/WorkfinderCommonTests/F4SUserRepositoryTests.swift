//
//  F4SUserRepositoryTests.swift
//  WorkfinderCommonTests
//
//  Created by Keith Dev on 08/08/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import XCTest
@testable import WorkfinderCommon

class F4SUserRepositoryTests: XCTestCase {
    
    func test_store_save_and_load() {
        let store = MockLocalStore()
        let sut = F4SUserRepository(localStore: store)
        let user = makeUser()
        sut.save(user: user)
        let retrievedUser = sut.load()
        assertUsersIdentical(a: user, b: retrievedUser)
    }
    
    func test_store_load_when_empty() {
        let store = MockLocalStore()
        let sut = F4SUserRepository(localStore: store)
        let user = sut.load()
        XCTAssertNil(user.uuid)
    }
    
    func test_load_with_obsolete_partner_storage_and_no_new_storage_partner() {
        let store = MockLocalStore()
        let sut = F4SUserRepository(localStore: store)
        var user = makeUser()
        user.partners = nil
        sut.save(user: user)
        store.setValue("partnerUuid_obsolete_storage", for: LocalStore.Key.partnerID)
        let retrievedUser = sut.load()
        XCTAssertTrue(retrievedUser.partners?.first?.uuid == "partnerUuid_obsolete_storage")
    }
    func test_load_with_obsolete_partner_storage_and_new_storage_partner() {
        let store = MockLocalStore()
        let sut = F4SUserRepository(localStore: store)
        let user = makeUser()
        sut.save(user: user)
        store.setValue("partnerUuid_obsolete_storage", for: LocalStore.Key.partnerID)
        let retrievedUser = sut.load()
        XCTAssertTrue(retrievedUser.partners?.first?.uuid == "partnerUuid_new_storage")
    }
    
    func assertUsersIdentical(a: F4SUserProtocol, b: F4SUserProtocol) {
        XCTAssertEqual(a.consenterEmail, b.consenterEmail)
        XCTAssertEqual(a.dateOfBirth, b.dateOfBirth)
        XCTAssertEqual(a.email, b.email)
        XCTAssertEqual(a.firstName, b.firstName)
        XCTAssertEqual(a.lastName, b.lastName)
        XCTAssertEqual(a.isOnboarded, b.isOnboarded)
        XCTAssertEqual(a.parentEmail, b.parentEmail)
        XCTAssertEqual(a.partners?.count, b.partners?.count)
        XCTAssertEqual(a.requiresConsent, b.requiresConsent)
        XCTAssertEqual(a.termsAgreed, b.termsAgreed)
    }

}

extension F4SUserRepositoryTests {
    func makeUser() -> F4SUserProtocol {
        return F4SUserInformation(
            uuid: "uuid",
            consenterEmail: "consenterEmail",
            parentEmail: "parentEmail",
            dateOfBirth: DateComponents(calendar: Calendar.current, year: 2000, month: 7, day: 28).date!,
            email: "email",
            firstName: "firstName",
            lastName: "lastName",
            requiresConsent: true,
            termsAgreed: false,
            vouchers: ["voucherUuid"],
            partners: [F4SUUIDDictionary(uuid: "partnerUuid_new_storage")],
            isOnboarded: false,
            isRegistered: false)
    }
}
