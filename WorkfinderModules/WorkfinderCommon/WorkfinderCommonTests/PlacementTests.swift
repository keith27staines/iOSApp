//
//  PlacementTests.swift
//  WorkfinderCommonTests
//
//  Created by Keith Dev on 05/02/2020.
//  Copyright © 2020 Founders4Schools. All rights reserved.
//

import XCTest
@testable import WorkfinderCommon

class PlacementTests: XCTestCase {

    func test_init() {
        let sut = Placement(companyUuid: "companyUuid", interestsList: [], status: PlacementStatus.completed, placementUuid: "placementUuid")
        XCTAssertEqual(sut.companyUuid, "companyUuid")
        XCTAssertTrue(sut.interestsList.isEmpty)
        XCTAssertEqual(sut.status, PlacementStatus.completed)
        XCTAssertEqual(sut.placementUuid, "placementUuid")
    }

}
