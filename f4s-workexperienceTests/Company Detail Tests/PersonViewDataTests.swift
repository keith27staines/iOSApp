//
//  PersonViewDataTests.swift
//  F4SPrototypesTests
//
//  Created by Keith Dev on 26/01/2019.
//  Copyright © 2019 Keith Staines. All rights reserved.
//

import XCTest
@testable import f4s_workexperience

class PersonViewDataTests: XCTestCase {

    var sut: PersonViewData!
    
    override func setUp() {
        sut = PersonViewData(uuid: "", firstName: "", lastName: "", bio: "", role: "", imageName: "", linkedInUrl: "")
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
        sut = nil
    }
    
    func test_fullName() {
        sut.firstName = "first"
        sut.lastName = "last"
        XCTAssertEqual(sut.fullName, "first last")
    }
    
    func test_fullNameAndRole() {
        sut.firstName = "first"
        sut.lastName = "last"
        sut.role = "role"
        XCTAssertEqual(sut.fullNameAndRole, "first last, role")
    }
    
    func test_isLinkedInVisible_urlIsNill() {
        sut.linkedInUrl = nil
        XCTAssertTrue(sut.islinkedInHidden)
    }
    
    func test_isLinkedInVisible_urlIsNotNill() {
        sut.linkedInUrl = "something"
        XCTAssertFalse(sut.islinkedInHidden)
    }

}
