//
//  F4SCompanyDatabaseMetadataTests.swift
//  WorkfinderCommonTests
//
//  Created by Keith Dev on 05/02/2020.
//  Copyright © 2020 Founders4Schools. All rights reserved.
//

import XCTest
@testable import WorkfinderCommon

class F4SCompanyDatabaseMetadataTests: XCTestCase {

    func test_initialise() {
        let date = Date()
        let sut = F4SCompanyDatabaseMetaData(created: date, urlString: "urlString", errors: nil)
        XCTAssertEqual(sut.created, date)
        XCTAssertEqual(sut.urlString, "urlString")
    }


}
