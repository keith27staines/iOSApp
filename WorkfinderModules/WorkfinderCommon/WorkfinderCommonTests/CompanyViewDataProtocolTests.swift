//
//  CompanyViewDataProtocolTests.swift
//  WorkfinderCommonTests
//
//  Created by Keith Dev on 08/08/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import XCTest
@testable import WorkfinderCommon

class CompanyViewDataProtocolTests: XCTestCase {

    func test_duedilIsHiden_not_hidden_when_url_exists() {
        let sut = TestCompanyViewData(logoUrlString: "url/logo", uuid: "uuid", appliedState: AppliedState.draft, companyName: "company", isAvailableForSearch: true, isFavourited: false, starRating: nil, industry: nil, description: nil, revenue: nil, growth: nil, employees: nil, industryIsHidden: true, postcode: nil, duedilUrl: "/duedilUrl", linkedinUrl: "/linkedin")
        XCTAssertFalse(sut.duedilIsHiden)
    }
    
    func test_duedilIsHiden_hidden_when_url_is_nil() {
        let sut = TestCompanyViewData(logoUrlString: "url/logo", uuid: "uuid", appliedState: AppliedState.draft, companyName: "company", isAvailableForSearch: true, isFavourited: false, starRating: nil, industry: nil, description: nil, revenue: nil, growth: nil, employees: nil, industryIsHidden: true, postcode: nil, duedilUrl: nil, linkedinUrl: nil)
        XCTAssertTrue(sut.duedilIsHiden)
    }
    
    func test_linkedinIsHiden_not_hidden_when_url_exists() {
        let sut = TestCompanyViewData(logoUrlString: "url/logo", uuid: "uuid", appliedState: AppliedState.draft, companyName: "company", isAvailableForSearch: true, isFavourited: false, starRating: nil, industry: nil, description: nil, revenue: nil, growth: nil, employees: nil, industryIsHidden: true, postcode: nil, duedilUrl: nil, linkedinUrl: "/linkedinUrl")
        XCTAssertFalse(sut.linkedinIsHidden)
    }
    
    func test_linkedinIsHiden_hidden_when_url_is_nil() {
        let sut = TestCompanyViewData(logoUrlString: "url/logo", uuid: "uuid", appliedState: AppliedState.draft, companyName: "company", isAvailableForSearch: true, isFavourited: false, starRating: nil, industry: nil, description: nil, revenue: nil, growth: nil, employees: nil, industryIsHidden: true, postcode: nil, duedilUrl: nil, linkedinUrl: nil)
        XCTAssertTrue(sut.linkedinIsHidden)
    }

}

// A test double just to provide a concrete implementation of CompanyViewDataProtocol
// in order to allow tests of the protocol's extensions
struct TestCompanyViewData : CompanyViewDataProtocol {
    var logoUrlString: String?
    
    var uuid: F4SUUID
    var appliedState: AppliedState
    var companyName: String
    var isAvailableForSearch: Bool
    var isFavourited: Bool
    var starRating: Float?
    var industry: String?
    var description: String?
    var revenue: Double?
    var growth: Double?
    var employees: Int?
    var industryIsHidden: Bool
    var postcode: String?
    var duedilUrl: String?
    var linkedinUrl: String?
    
}
