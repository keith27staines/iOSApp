//
//  WorkfinderEndpointTests.swift
//  WorkfinderCommonTests
//
//  Created by Keith Dev on 05/02/2020.
//  Copyright © 2020 Founders4Schools. All rights reserved.
//

import XCTest
@testable import WorkfinderCommon

class WorkfinderEndpointTests: XCTestCase {

    func test_endpoints() {
        let endpoint = WorkfinderEndpoint(baseUrlString: "baseUrl")
        XCTAssertEqual(endpoint.allPartnersUrl,"baseUrl/v2/partner")
        XCTAssertEqual(endpoint.allPlacementsUrl,"baseUrl/v2/placement")
        XCTAssertEqual(endpoint.baseUrl2, "baseUrl/v2")
        XCTAssertEqual(endpoint.companyDatabaseUrl,"baseUrl/v2/company/dump/full")
        XCTAssertEqual(endpoint.companyDocumentsUrl,"baseUrl/v2/company")
        XCTAssertEqual(endpoint.companyUrl,"baseUrl/v2/company")
        XCTAssertEqual(endpoint.contentUrl,"baseUrl/v2/content")
        XCTAssertEqual(endpoint.messagesInThreadUrl,"baseUrl/v2/messaging/")
        XCTAssertEqual(endpoint.offerUrl,"baseUrl/v2/placement")
        XCTAssertEqual(endpoint.optionsForThreadUrl,"baseUrl/v2/messaging/")
        XCTAssertEqual(endpoint.patchPlacementUrl,"baseUrl/v2/placement")
        XCTAssertEqual(endpoint.placementUrl,"baseUrl/v2/placement")
        XCTAssertEqual(endpoint.postDocumentsUrl,"baseUrl/v2/placement")
        XCTAssertEqual(endpoint.recommendationURL,"baseUrl/v2/recommend")
        XCTAssertEqual(endpoint.registerPushNotifictionToken,"baseUrl/v2/register")
        XCTAssertEqual(endpoint.registerVendorId,"baseUrl/v2/register")
        XCTAssertEqual(endpoint.roleUrl,"baseUrl/v2/company")
        XCTAssertEqual(endpoint.sendMessageForThreadUrl,"baseUrl/v2/messaging/")
        XCTAssertEqual(endpoint.shortlistCompanyUrl,"baseUrl/v2/favourite")
        XCTAssertEqual(endpoint.templateUrl,"baseUrl/v2/cover-template")
        XCTAssertEqual(endpoint.unreadMessagesCountUrl,"baseUrl/v2/user/status")
        XCTAssertEqual(endpoint.unshortlistCompanyUrl,"baseUrl/v2/favourite")
        XCTAssertEqual(endpoint.unreadMessagesCountUrl,"baseUrl/v2/user/status")
        XCTAssertEqual(endpoint.updateUserProfileUrl,"baseUrl/v2/user/me")
        XCTAssertEqual(endpoint.unshortlistCompanyUrl,"baseUrl/v2/favourite")
        XCTAssertEqual(endpoint.versionUrl,"baseUrl/validation/ios-version/")
        XCTAssertEqual(endpoint.voucherUrl,"baseUrl/v2/voucher/")
    }

}
