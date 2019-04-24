//
//  CompanyViewModelTests.swift
//  F4SPrototypesTests
//
//  Created by Keith Dev on 26/01/2019.
//  Copyright © 2019 Keith Staines. All rights reserved.
//

import XCTest
@testable import f4s_workexperience

class CompanyViewModelTests: XCTestCase {
    
    var sut: CompanyViewModel!
    var coordinatingDelegate: CoordinatingDelegate!
    var company: CompanyViewData!
    var person: PersonViewData!
    
    override func setUp() {
        super.setUp()
        let company = Company(id: 1, created: Date(), modified: Date(), isRemoved: false, uuid: UUID().uuidString, name: "companyName", logoUrl: "logoUrlString", industry: "industry", latitude: 45, longitude: 45, summary: "summary", employeeCount: 1, turnover: 1, turnoverGrowth: 1, rating: 1, ratingCount: 1, sourceId: "sourceId", hashtag: "hashtag", companyUrl: "companyUrlString")
        person = PersonViewData()
        coordinatingDelegate = CoordinatingDelegate()
        sut = CompanyViewModel(coordinatingDelegate: coordinatingDelegate, company: company, people: [person])
        self.company = sut.companyViewData
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

}

class CoordinatingDelegate: CompanyViewModelCoordinatingDelegate {
    
    func companyViewModelDidRefresh(_ viewModel: CompanyViewModel) {
        refreshedModelCount += 1
    }
    
    var refreshedModelCount: Int = 0
    var didComplete = false
    var applyToCompany: CompanyViewData? = nil
    var showLinkedInForPerson: PersonViewData? = nil
    var showLinkedInForCompany: CompanyViewData? = nil
    var showDuedilForCompany: CompanyViewData? = nil
    var showLocationForCompany: CompanyViewData? = nil
    var showShareForCompany: CompanyViewData? = nil
    
    func companyViewModelDidComplete(_ viewModel: CompanyViewModel) {
        didComplete = true
    }
    
    func companyViewModel(_ viewModel: CompanyViewModel, applyTo: CompanyViewData) {
        applyToCompany = applyTo
    }
    
    func companyViewModel(_ viewModel: CompanyViewModel, requestsShowLinkedIn person: PersonViewData) {
        showLinkedInForPerson = person
    }
    
    func companyViewModel(_ viewModel: CompanyViewModel, requestsShowLinkedIn company: CompanyViewData) {
        showLinkedInForCompany = company
    }
    
    func companyViewModel(_ viewModel: CompanyViewModel, requestedShowDuedil company: CompanyViewData) {
        showDuedilForCompany = company
    }
    
    func companyViewModel(_ viewModel: CompanyViewModel, showLocation company: CompanyViewData) {
        showLocationForCompany = company
    }
    
    func companyViewModel(_ viewModel: CompanyViewModel, showShare company: CompanyViewData) {
        showShareForCompany = company
    }
}
