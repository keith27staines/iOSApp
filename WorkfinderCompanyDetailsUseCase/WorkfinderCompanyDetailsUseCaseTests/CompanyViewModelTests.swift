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
    var coordinatingDelegate: CoordinatingDelegate!
    var company: CompanyViewData!
    var person: PersonViewData!
    
    override func setUp() {
        super.setUp()
        let company = Company(id: 1, created: Date(), modified: Date(), uuid: UUID().uuidString, name: "companyName", logoUrl: "logoUrlString", industry: "industry", latitude: 45, longitude: 45, summary: "summary", employeeCount: 1, turnover: 1, turnoverGrowth: 1, rating: 1, ratingCount: 1, sourceId: "sourceId", hashtag: "hashtag", companyUrl: "companyUrlString")
        person = PersonViewData()
        let favouritesModel = makeFavouritingModel()
        coordinatingDelegate = CoordinatingDelegate()
        sut = CompanyViewModel(coordinatingDelegate: coordinatingDelegate,
                               company: company,
                               people: [person],
                               favouritingModel: favouritesModel)
        self.company = sut.companyViewData
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func makeFavouritingModel() -> CompanyFavouritesModel {
        let shortlistJson = F4SShortlistJson()
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

class MockFavouritingRepository: F4SFavouritesRepositoryProtocol {
    var favourites = [F4SUUID: Shortlist]()
    
    func loadFavourites() -> [Shortlist] {
        return Array(favourites.values)
    }
    
    func removeFavourite(uuid: F4SUUID) {
        favourites[uuid] = nil
    }
    
    func addFavourite(_ item: Shortlist) {
        favourites[item.uuid] = item
    }
}

class MockFavouritingService: CompanyFavouritingServiceProtocol {
    var apiName: String = "MockFavouritingService/api"
    var expectedFavouriteResult: F4SNetworkResult<F4SShortlistJson>
    var expectedUnfavouriteResult: F4SNetworkResult<F4SUUID>
    
    public init(expectedFavouriteResult: F4SNetworkResult<F4SShortlistJson>,
                expectedUnfavouriteResult: F4SNetworkResult<F4SUUID>) {
        self.expectedFavouriteResult = expectedFavouriteResult
        self.expectedUnfavouriteResult = expectedUnfavouriteResult
    }
    
    func favourite(companyUuid: F4SUUID, completion: @escaping (F4SNetworkResult<F4SShortlistJson>) -> Void) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            completion(strongSelf.expectedFavouriteResult)
        }
    }
    
    func unfavourite(shortlistUuid: String, completion: @escaping (F4SNetworkResult<F4SUUID>) -> Void) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            completion(strongSelf.expectedUnfavouriteResult)
        }
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
