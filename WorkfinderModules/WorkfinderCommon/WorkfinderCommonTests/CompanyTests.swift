//
//  CompanyTests.swift
//  WorkfinderCommonTests
//
//  Created by Keith Dev on 05/02/2020.
//  Copyright © 2020 Founders4Schools. All rights reserved.
//

import XCTest
@testable import WorkfinderCommon

class CompanyTests:XCTestCase {
    lazy var date = Date()
    lazy var sut = Company(
        id: 123456,
        created: date,
        modified: date,
        isAvailableForSearch: true,
        uuid: "companyUuid",
        name: "name",
        logoUrl: "logoUrl",
        industry: "industry",
        latitude: 50,
        longitude: 60,
        summary: "summary",
        employeeCount: 1,
        turnover: 1.2345,
        turnoverGrowth: 2.345,
        rating: 3.456,
        ratingCount: 4.567,
        sourceId: "sourceId",
        hashtag: "hashtag",
        companyUrl: "companyUrl")
    
    func test_initialise() {
        XCTAssertEqual(sut.id, 123456)
        XCTAssertEqual(sut.created, date)
        XCTAssertEqual(sut.modified, date)
        XCTAssertEqual(sut.isAvailableForSearch, true)
        XCTAssertEqual(sut.uuid, "companyUuid")
        XCTAssertEqual(sut.name, "name")
        XCTAssertEqual(sut.logoUrl, "logoUrl")
        XCTAssertEqual(sut.industry, "industry")
        XCTAssertEqual(sut.latitude, 50)
        XCTAssertEqual(sut.longitude, 60)
        XCTAssertEqual(sut.summary, "summary")
        XCTAssertEqual(sut.employeeCount, 1)
        XCTAssertEqual(sut.turnover, 1.2345)
        XCTAssertEqual(sut.turnoverGrowth, 2.345)
        XCTAssertEqual(sut.rating, 3.456)
        XCTAssertEqual(sut.ratingCount, 4.567)
        XCTAssertEqual(sut.sourceId, "sourceId")
        XCTAssertEqual(sut.hashtag, "hashtag")
        XCTAssertEqual(sut.companyUrl, "companyUrl")
    }
    
    func test_sortingName() {
        sut.name = "Workfinder F4S LTD"
        XCTAssertEqual(sut.sortingName, "workfinder f4s")
    }
    
    func test_equality_when_same() {
        let company1 = sut
        let company2 = sut
        XCTAssertEqual(company1, company2)
    }
    
    func test_equality_when_differ_by_uuid() {
        let company1 = sut
        var company2 = sut
        company2.uuid = "different uuid"
        XCTAssertNotEqual(company1, company2)
    }
    
    func test_equality_when_differ_only_by_name() {
        let company1 = sut
        var company2 = sut
        company2.name = "different name"
        XCTAssertEqual(company1, company2)
    }
    
    func test_hash() {
        var hasher = Hasher()
        hasher.combine(sut.uuid)
        hasher.combine(sut.latitude)
        hasher.combine(sut.longitude)
        XCTAssertEqual(hasher.finalize(), sut.hashValue)
    }
    
}
