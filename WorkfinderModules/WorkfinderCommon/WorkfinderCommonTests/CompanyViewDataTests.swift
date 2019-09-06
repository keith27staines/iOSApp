//
//  CompanyViewDataTests.swift
//  F4SPrototypesTests
//
//  Created by Keith Dev on 25/01/2019.
//  Copyright © 2019 Keith Staines. All rights reserved.
//

import XCTest
@testable import WorkfinderCommon

class CompanyViewDataTests: XCTestCase {
    
    var sut: CompanyViewData!
    override func setUp() {
        super.setUp()
        sut = makeCompany()
    }
    
    override func tearDown() {
        super.tearDown()
        sut = nil
    }
    
    func testEmployeesString_999() {
        sut.employees = 999
        XCTAssertEqual(sut.employeesString!, "Employees: 999")
    }
    
    func testEmployeesString_1001() {
        sut.employees = 1001
        XCTAssertEqual(sut.employeesString!, "Employees: 1.0k")
    }
    
    func testEmployeesString_999_999() {
        sut.employees = 999_999
        XCTAssertEqual(sut.employeesString!, "Employees: 1.0m")
    }
    
    func testRating_isHidden_NilRating() {
        sut.starRating = nil
        XCTAssertTrue(sut.starRatingIsHidden)
    }
    
    func testRating_isHidden_0Rating() {
        sut.starRating = 0
        XCTAssertTrue(sut.starRatingIsHidden)
    }
    
    func testRating_isHidden_1Rating() {
        sut.starRating = 1
        XCTAssertFalse(sut.starRatingIsHidden)
    }
    
    func testRevenue_isHidden_NilRevenue() {
        sut.revenue = nil
        XCTAssertTrue(sut.revenueIsHidden)
    }
    
    func testRevenue_isHidden_0Revenue() {
        sut.revenue = 0
        XCTAssertTrue(sut.revenueIsHidden)
    }
    
    func testRevenue_isHidden_1Revenue() {
        sut.revenue = 1
        XCTAssertFalse(sut.revenueIsHidden)
    }
    
    func testGrowth_isHidden_NilGrowth() {
        sut.growth = nil
        XCTAssertTrue(sut.growthIsHidden)
    }
    
    func testGrowth_isHidden_0Growth() {
        sut.growth = 0
        XCTAssertTrue(sut.growthIsHidden)
    }
    
    func testGrowth_isHidden_1Growth() {
        sut.growth = 1
        XCTAssertFalse(sut.growthIsHidden)
    }
    
    
    func testEmployees_isHidden_NilEmployees() {
        sut.employees = nil
        XCTAssertTrue(sut.employeesIsHidden)
    }
    
    func testEmployees_isHidden_0Employees() {
        sut.employees = 0
        XCTAssertTrue(sut.employeesIsHidden)
    }
    
    func testEmployees_isHidden_1Employees() {
        sut.employees = 1
        XCTAssertFalse(sut.employeesIsHidden)
    }
}

extension CompanyViewDataTests {
    func makeCompany() -> CompanyViewData {
        let now = Date()
        let company = Company(
            id: 1,
            created: now,
            modified: now,
            isAvailableForSearch: true,
            uuid: "uuid",
            name: "name",
            logoUrl: "logoUrlString",
            industry: "industry",
            latitude: 45,
            longitude: 45,
            summary: "summary",
            employeeCount: 1,
            turnover: 1,
            turnoverGrowth: 1,
            rating: 1,
            ratingCount: 1,
            sourceId: "sourceId",
            hashtag: "hashtag",
            companyUrl: "companyUrlString")
        return CompanyViewData(company: company)
    }
}
