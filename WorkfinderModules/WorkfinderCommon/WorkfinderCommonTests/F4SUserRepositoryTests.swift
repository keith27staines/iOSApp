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
    
    func test_initialise() {
        let store = MockLocalStore()
        let sut = UserRepository(localStore: store)
        XCTAssertTrue(sut.localStore as! MockLocalStore === store)
    }

    func test_store_save_and_load() {
        let store = MockLocalStore()
        let sut = UserRepository(localStore: store)
        let dob = DateComponents(calendar: Calendar.current, year: 2000, month: 1, day: 1).date!
        let user = Candidate(uuid: "uuid", email: "email", firstName: "first", lastName: "last", consenterEmail: "consenter", parentEmail: "parent", requiresConsent: true, dateOfBirth: dob, partners: nil, termsAgreed: true)
        sut.save(candidate: user)
        let retrievedUser = sut.loadCandidate()
        assertUsersIdentical(a: user, b: retrievedUser)
    }
    
    func test_store_load_when_empty() {
        let store = MockLocalStore()
        let sut = UserRepository(localStore: store)
        let user = sut.loadCandidate()
        XCTAssertNil(user.uuid)
    }
    
    func assertUsersIdentical(a: Candidate, b: Candidate) {
        XCTAssertEqual(a.consenterEmail, b.consenterEmail)
        XCTAssertEqual(a.dateOfBirth, b.dateOfBirth)
        XCTAssertEqual(a.email, b.email)
        XCTAssertEqual(a.firstName, b.firstName)
        XCTAssertEqual(a.lastName, b.lastName)
        XCTAssertEqual(a.parentEmail, b.parentEmail)
        XCTAssertEqual(a.partners?.count, b.partners?.count)
        XCTAssertEqual(a.requiresConsent, b.requiresConsent)
        XCTAssertEqual(a.termsAgreed, b.termsAgreed)
    }
}

