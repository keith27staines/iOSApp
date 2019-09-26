//
//  CompanyViewModelTests.swift
//  F4SPrototypesTests
//
//  Created by Keith Dev on 26/01/2019.
//  Copyright © 2019 Keith Staines. All rights reserved.
//

import XCTest
import WorkfinderCommon
@testable import WorkfinderCompanyDetailsUseCase

class CompanyViewModelTests: XCTestCase {
    
    var sut: CompanyViewModel!
    var coordinatingDelegate: MockCoordinatingDelegate!
    var company: CompanyViewData!
    var person: PersonViewData!
    
    override func setUp() {
        super.setUp()
        let company = Company(id: 1, created: Date(), modified: Date(), uuid: UUID().uuidString, name: "companyName", logoUrl: "logoUrlString", industry: "industry", latitude: 45, longitude: 45, summary: "summary", employeeCount: 1, turnover: 1, turnoverGrowth: 1, rating: 1, ratingCount: 1, sourceId: "sourceId", hashtag: "hashtag", companyUrl: "companyUrlString")
        person = PersonViewData()
        let favouritesModel = makeFavouritingModel()
        let mockCompanyService = MockF4SCompanyService()
        let mockAllowedToApplyLogic = MockAllowedToApplyLogic()
        let mockCompanyDocumentsModel = MockF4SCompanyDocumentsModel()
        
        coordinatingDelegate = MockCoordinatingDelegate()
        sut = CompanyViewModel(coordinatingDelegate: coordinatingDelegate,
                               company: company,
                               people: [person],
                               companyService: mockCompanyService,
                               favouritingModel: favouritesModel,
                               allowedToApplyLogic: mockAllowedToApplyLogic,
                               companyDocumentsModel: mockCompanyDocumentsModel)
        self.company = sut.companyViewData
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func makeFavouritingModel() -> CompanyFavouritesModel {
        let shortlistJson = F4SShortlistJson(uuid: "uuid", companyUuid: "companyUuid")
        let expectedFavouriteResult =  F4SNetworkResult.success(shortlistJson)
        let expectedUnfavouriteResult = F4SNetworkResult.success("uuid")
        let favouritingService = MockFavouritingService(expectedFavouriteResult: expectedFavouriteResult, expectedUnfavouriteResult: expectedUnfavouriteResult)
        let favouritingRepository = MockFavouritingRepository()
        let favouritesModel = CompanyFavouritesModel(
            favouritingService: favouritingService,
            favouritesRepository: favouritingRepository)
        return favouritesModel
    }
    
}

class MockCoordinatingDelegate: CompanyViewModelCoordinatingDelegate {
    
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
    
    func companyViewModel(_ viewModel: CompanyViewModel, applyTo: CompanyViewData, continueFrom: F4STimelinePlacement?) {
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