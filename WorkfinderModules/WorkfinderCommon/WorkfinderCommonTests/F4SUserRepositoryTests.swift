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
        var candidate = Candidate()
        candidate.dateOfBirth = "some date string"
        sut.save(candidate: candidate)
        let retrievedCandidate = sut.loadCandidate()
        XCTAssertEqual(retrievedCandidate.dateOfBirth, candidate.dateOfBirth)
    }
    
    func test_store_load_when_empty() {
        let store = MockLocalStore()
        let sut = UserRepository(localStore: store)
        let user = sut.loadCandidate()
        XCTAssertNil(user.uuid)
    }
}

