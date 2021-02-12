//
//  RequestAppReviewLogicTests.swift
//  WorkfinderUITests
//
//  Created by Keith Staines on 11/02/2021.
//  Copyright © 2021 Workfinder. All rights reserved.
//

import XCTest
import WorkfinderCommon

class RequestAppReviewLogicTests: XCTestCase {
    
    let currentAppVersion: String = "3.2.1"
    let ninetyDays: TimeInterval = 90 * 24 * 3600
    
    func test_isLastRequestOlderThan90Days_when_never_requested() {
        let sut = makeSUT(lastReviewRequestDate: nil, lastReviewedVersion: nil)
        XCTAssertTrue(sut.isLastRequestOlderThan90Days)
    }
    
    func test_isLastRequestOlderThan90Days_when_last_requested_less_than_90_days_ago() {
        let now = Date()
        let lastRquestDate = now.addingTimeInterval(-ninetyDays+1)
        let sut = makeSUT(lastReviewRequestDate: lastRquestDate, lastReviewedVersion: nil)
        XCTAssertFalse(sut.isLastRequestOlderThan90Days)
    }
    
    func test_isLastRequestOlderThan90Days_when_last_requested_more_than_90_days_ago() {
        let now = Date()
        let lastRquestDate = now.addingTimeInterval(-ninetyDays-1)
        let sut = makeSUT(lastReviewRequestDate: lastRquestDate, lastReviewedVersion: nil)
        XCTAssertTrue(sut.isLastRequestOlderThan90Days)
    }
    
    func test_isCurrentVersionDifferentFromLastReview_when_no_last_review() {
        let sut = makeSUT(lastReviewRequestDate: nil, lastReviewedVersion: nil)
        XCTAssertTrue(sut.isCurrentVersionDifferentFromLastReviewedVersion)
    }
    
    func test_isCurrentVersionDifferentFromLastReview_when_last_reviewed_against_different_version() {
        let sut = makeSUT(lastReviewRequestDate: nil, lastReviewedVersion: "1.2.3")
        XCTAssertTrue(sut.isCurrentVersionDifferentFromLastReviewedVersion)
    }
    
    func test_isCurrentVersionDifferentFromLastReview_when_last_reviewed_against_same_version() {
        let sut = makeSUT(lastReviewRequestDate: nil, lastReviewedVersion: currentAppVersion)
        XCTAssertFalse(sut.isCurrentVersionDifferentFromLastReviewedVersion)
    }
    
    func test_makeRequest_updates_local_store_if_all_tests_pass() {
        let now = Date()
        let sut = makeSUT(
            lastReviewRequestDate: nil, lastReviewedVersion: nil)
        XCTAssertTrue(sut.isLastRequestOlderThan90Days)
        XCTAssertTrue(sut.isCurrentVersionDifferentFromLastReviewedVersion)
        XCTAssertTrue(sut.shouldMakeRequest)
        var wasCalledBack = false
        sut.makeRequestCallback = {
            wasCalledBack = true
        }
        sut.makeRequest()
        XCTAssertTrue(wasCalledBack)
        XCTAssertTrue(sut.lastRequestDate >= now)
        XCTAssertFalse(sut.shouldMakeRequest)
    }
    
    func test_makeRequest_does_not_update_local_store_if_date_test_fails_and_version_test_passes() {
        let now = Date()
        let sut = makeSUT(
            lastReviewRequestDate: now.addingTimeInterval(-ninetyDays+1),
            lastReviewedVersion: "1.2.3"
        )
        XCTAssertFalse(sut.isLastRequestOlderThan90Days)
        XCTAssertTrue(sut.isCurrentVersionDifferentFromLastReviewedVersion)
        XCTAssertFalse(sut.shouldMakeRequest)
        var wasCalledBack = false
        sut.makeRequestCallback = { wasCalledBack = true }
        sut.makeRequest()
        XCTAssertFalse(wasCalledBack)
    }
    
    func test_makeRequest_does_not_update_local_store_date_test_passes_and_version_test_fails() {
        let now = Date()
        let sut = makeSUT(
            lastReviewRequestDate: now.addingTimeInterval(-ninetyDays-1),
            lastReviewedVersion: currentAppVersion
        )
        XCTAssertTrue(sut.isLastRequestOlderThan90Days)
        XCTAssertFalse(sut.isCurrentVersionDifferentFromLastReviewedVersion)
        XCTAssertFalse(sut.shouldMakeRequest)
        var wasCalledBack = false
        sut.makeRequestCallback = { wasCalledBack = true }
        sut.makeRequest()
        XCTAssertFalse(wasCalledBack)
    }
    
    func test_isAtLeastNthApplicationSinceLastReview_when_no_applications() {
        let sut = makeSUT(
            lastReviewRequestDate: nil,
            lastReviewedVersion: nil,
            requiredApplicationsSinceLastReview: 3,
            applicationsSinceLastReview: nil
        )
        XCTAssertTrue(sut.isEnoughApplications)
        XCTAssertTrue(sut.shouldMakeRequest)
    }
    
    func test_isAEnoughApplications_when_nil_applications() {
        let sut = makeSUT(
            lastReviewRequestDate: nil,
            lastReviewedVersion: nil,
            requiredApplicationsSinceLastReview: 3,
            applicationsSinceLastReview: nil
        )
        XCTAssertTrue(sut.isEnoughApplications)
        XCTAssertTrue(sut.shouldMakeRequest)
    }
    
    func test_isEnoughApplications_when_0_applications() {
        let sut = makeSUT(
            lastReviewRequestDate: nil,
            lastReviewedVersion: nil,
            requiredApplicationsSinceLastReview: 3,
            applicationsSinceLastReview: 0
        )
        XCTAssertFalse(sut.isEnoughApplications)
        XCTAssertFalse(sut.shouldMakeRequest)
    }
    
    func test_makeRequest_callsBack_after_on_4th_applications() {
        var callbackCalled: Bool = false
        let sut = makeSUT(
            lastReviewRequestDate: nil,
            lastReviewedVersion: nil,
            requiredApplicationsSinceLastReview: 3,
            applicationsSinceLastReview: 0
        )
        sut.makeRequestCallback = { callbackCalled = true }
        XCTAssertEqual(sut.applicationCount, 0)
        XCTAssertFalse(callbackCalled)
        sut.makeRequest()
        XCTAssertFalse(callbackCalled)
        XCTAssertEqual(sut.applicationCount, 1)
        sut.makeRequest()
        XCTAssertFalse(callbackCalled)
        XCTAssertEqual(sut.applicationCount, 2)
        sut.makeRequest()
        XCTAssertFalse(callbackCalled)
        XCTAssertEqual(sut.applicationCount, 3)
        sut.makeRequest()
        XCTAssertTrue(callbackCalled)
        XCTAssertEqual(sut.applicationCount, 0)
    }

    let store = MockLocalStore()
    
    func makeSUT(
        lastReviewRequestDate: Date?,
        lastReviewedVersion: String?,
        requiredApplicationsSinceLastReview: Int = 3,
        applicationsSinceLastReview: Int? = nil
    ) -> RequestAppReviewLogic {
        
        store.setValue(lastReviewRequestDate, for: .lastReviewRequestDate)
        store.setValue(lastReviewedVersion, for: .lastReviewedVersion)
        store.setValue(applicationsSinceLastReview, for: .applicationsSinceLastReview)
        let sut = RequestAppReviewLogic(
            localStore: store,
            currentAppVersion: currentAppVersion,
            requiredApplicationsSinceLastReview: requiredApplicationsSinceLastReview,
            makeRequestCallback: {}
        )
        XCTAssertEqual(sut.currentAppVersion, currentAppVersion)
        return sut
    }

}
