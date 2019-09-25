//
//  F4SPlacementTests.swift
//  WorkfinderCommonTests
//
//  Created by Keith Dev on 12/08/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import XCTest
@testable import WorkfinderCommon

class F4SPlacementTests: XCTestCase {

    func test_initialise_with_timeline_placement() {
        let timelinePlacement = F4STimelinePlacement(userUuid: "userUuid", companyUuid: "companyUuid", placementUuid: "placementUuid")
        let sut = F4SPlacement(timelinePlacement: timelinePlacement)
        XCTAssertEqual(sut.userUuid, "userUuid")
        XCTAssertEqual(sut.companyUuid, "companyUuid")
        XCTAssertEqual(sut.placementUuid, "placementUuid")
        XCTAssertEqual(sut.status, timelinePlacement.workflowState)
        XCTAssertTrue(sut.interestList.isEmpty)
    }
    
    func test_initialise_with_values() {
        let sut = F4SPlacement(userUuid: "userUuid", companyUuid: "companyUuid", interestList: [F4SInterest(id: 1, uuid: "interestUuid", name: "interestName")], status: F4SPlacementState.confirmed, placementUuid: "placementUuid")
        XCTAssertEqual(sut.companyUuid, "companyUuid")
        XCTAssertEqual(sut.placementUuid, "placementUuid")
        XCTAssertEqual(sut.status, F4SPlacementState.confirmed)
        XCTAssertEqual(sut.interestList.first?.uuid, "interestUuid")
    }
    
    func test_decode() {
        let json = """
        {
            \"user_uuid\": \"userUuid\",
            \"company_uuid\": \"companyUuid\",
            \"placement_uuid\": \"placementUuid\",
            \"status\": \"confirmed\",
            \"interests\": [
                {
                    \"id\": 1,
                    \"uuid\": \"interestUuid\",
                    \"name\": \"interestName\"
                }
            ]
        }
        """
        let data = json.data(using: String.Encoding.utf8)!
        let sut = try! JSONDecoder().decode(F4SPlacement.self, from: data)
        XCTAssertEqual(sut.companyUuid, "companyUuid")
        XCTAssertEqual(sut.userUuid, "userUuid")
        XCTAssertEqual(sut.placementUuid, "placementUuid")
        XCTAssertEqual(sut.status, F4SPlacementState.confirmed)
        XCTAssertEqual(sut.interestList.first?.uuid, "interestUuid")
    }

}
