//
//  F4SInterestTests.swift
//  WorkfinderCommonTests
//
//  Created by Keith Dev on 06/08/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import XCTest
@testable import WorkfinderCommon

class F4SInterestTests: XCTestCase {

    func test_interest_initialise() {
        let sut = F4SInterest(id: 1234, uuid: "uuid", name: "name")
        XCTAssertTrue(sut.id == 1234)
        XCTAssertTrue(sut.uuid == "uuid")
        XCTAssertTrue(sut.name == "name")
    }
    
    func test_interests_uuidList() {
        let interests = [
            F4SInterest(id: 1, uuid: "uuid1", name: "name1"),
            F4SInterest(id: 2, uuid: "uuid2", name: "name2"),
            F4SInterest(id: 3, uuid: "uuid3", name: "name3"),
        ]
        XCTAssertTrue(interests.uuidList == [
            "uuid1", "uuid2", "uuid3"])
    }
    
    func test_interest_hashes_are_equal_when_interest_uuids_are_equal() {
        let interest1 = F4SInterest(id: 9876, uuid: "uuid", name: "differentName")
        let interest2 = F4SInterest(id: 1234, uuid: "uuid", name: "name")
        var hasher1 = Hasher()
        var hasher2 = Hasher()
        interest1.hash(into: &hasher1)
        interest2.hash(into: &hasher2)
        let hash1 = hasher1.finalize()
        let hash2 = hasher2.finalize()
        XCTAssertEqual(hash1, hash2)
    }
    
    func test_interests_hashes_differ_when_interest_uuids_differ() {
        let interest1 = F4SInterest(id: 1234, uuid: "uuid1", name: "name")
        let interest2 = F4SInterest(id: 1234, uuid: "uuid2", name: "name")
        var hasher1 = Hasher()
        var hasher2 = Hasher()
        interest1.hash(into: &hasher1)
        interest2.hash(into: &hasher2)
        let hash1 = hasher1.finalize()
        let hash2 = hasher2.finalize()
        XCTAssertNotEqual(hash1, hash2)
    }
    
    func test_interests_are_equal_if_uuids_equal() {
        let interest1 = F4SInterest(id: 1234, uuid: "uuid", name: "name")
        let interest2 = F4SInterest(id: 9876, uuid: "uuid", name: "otherName")
        XCTAssertEqual(interest1, interest2)
    }

    func test_interests_are_not_equal_if_uuids_differ() {
        let interest1 = F4SInterest(id: 1234, uuid: "uuid1", name: "name")
        let interest2 = F4SInterest(id: 1234, uuid: "uuid2", name: "name")
        XCTAssertNotEqual(interest1, interest2)
    }
}
