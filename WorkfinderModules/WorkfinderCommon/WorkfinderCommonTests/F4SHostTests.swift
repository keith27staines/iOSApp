//
//  F4SHostTests.swift
//  WorkfinderCommonTests
//
//  Created by Keith Dev on 05/02/2020.
//  Copyright © 2020 Founders4Schools. All rights reserved.
//

import XCTest
@testable import WorkfinderCommon

class F4SHostTests: XCTestCase {

    class F4SHostTests: XCTestCase {
        func test_initialise() {
            let sut = Host(
                uuid: "hostUuid",
                displayName: "displayName",
                firstName: "firstName",
                lastName: "lastName",
                profileUrl: "profileUrl",
                imageUrl: "imageUrl",
                gender: "gender",
                isInterestedInHosting: true,
                isCurrentEmployee: true,
                role: "role",
                summary: "summary")
            XCTAssertEqual(sut.uuid, "hostUuid")
            XCTAssertEqual(sut.displayName, "displayName")
            XCTAssertEqual(sut.firstName, "firstName")
            XCTAssertEqual(sut.lastName, "lastName")
            XCTAssertEqual(sut.linkedinUrlString, "profileUrl")
            XCTAssertEqual(sut.photoUrl, "imageUrl")
            XCTAssertEqual(sut.gender, "gender")
            XCTAssertEqual(sut.isInterestedInHosting, true)
            XCTAssertEqual(sut.isCurrentEmployee, true)
            XCTAssertEqual(sut.role, "role")
            XCTAssertEqual(sut.description, "summary")
        }
    }


}
