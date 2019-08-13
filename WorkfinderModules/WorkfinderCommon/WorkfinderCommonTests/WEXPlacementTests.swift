//
//  WEXPlacementTests.swift
//  WorkfinderCommonTests
//
//  Created by Keith Dev on 12/08/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import XCTest
@testable import WorkfinderCommon

class WEXCreatePlacementJsonTests: XCTestCase {
    
    func test_WEXCreatePlacementJson_initialise() {
        let sut = WEXCreatePlacementJson(user: "user", roleUuid: "role", company: "company", vendor: "vendor", interests: ["interest1"])
        XCTAssertTrue(sut.userUuid == "user")
        XCTAssertTrue(sut.roleUuid == "role")
        XCTAssertTrue(sut.companyUuid == "company")
        XCTAssertTrue(sut.vendorUuid == "vendor")
        XCTAssertTrue(sut.interests == ["interest1"])
    }
    
    func test_WEXCreatePlacement_decode() {
        let json = """
        {
            \"user_uuid\": \"user\",
            \"role_uuid\": \"role\",
            \"company_uuid\": \"company\",
            \"vendor_uuid\": \"vendor\",
            \"interests\": [
                \"interest1\",
                \"interest2\"
            ]
        }
        """
        let data = json.data(using: String.Encoding.utf8)!
        let sut = try! JSONDecoder().decode(WEXCreatePlacementJson.self, from: data)
        XCTAssertTrue(sut.userUuid == "user")
        XCTAssertTrue(sut.roleUuid == "role")
        XCTAssertTrue(sut.companyUuid == "company")
        XCTAssertTrue(sut.vendorUuid == "vendor")
        XCTAssertTrue(sut.interests == ["interest1","interest2"])
    }
}

class WEXPlacementJsonTests: XCTestCase {
    
    func test_CreatePlacementJson_initialise() {
        let sut = WEXPlacementJson(uuid: "uuid", user: "user", company: "company", vendor: "vendor", interests: ["interest1"])
        XCTAssertTrue(sut.uuid == "uuid")
        XCTAssertTrue(sut.userUuid == "user")
        XCTAssertTrue(sut.companyUuid == "company")
        XCTAssertTrue(sut.vendorUuid == "vendor")
        XCTAssertTrue(sut.interests == ["interest1"])
    }
    
    func test_WEXPlacementJson_decode() {
        let json = """
        {
            \"user_uuid\": \"user\",
            \"role_uuid\": \"role\",
            \"company_uuid\": \"company\",
            \"vendor_uuid\": \"vendor\",
            \"workflow_state\": \"no_parental_consent\",
            \"interests\": [
                \"interest1\",
                \"interest2\"
            ]
        }
        """
        let data = json.data(using: String.Encoding.utf8)!
        let sut = try! JSONDecoder().decode(WEXPlacementJson.self, from: data)
        XCTAssertTrue(sut.userUuid == "user")
        XCTAssertTrue(sut.roleUuid == "role")
        XCTAssertTrue(sut.companyUuid == "company")
        XCTAssertTrue(sut.vendorUuid == "vendor")
        XCTAssertTrue(sut.interests == ["interest1","interest2"])
        XCTAssertTrue(sut.workflowState! == .noParentalConsent)
    }
}

