//
//  AllowedToApplyLogicTests.swift
//  WorkfinderAppLogicTests
//
//  Created by Keith Dev on 01/08/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import XCTest
import WorkfinderCommon
import WorkfinderNetworking
@testable import WorkfinderAppLogic

class AllowedToApplyLogicTests: XCTestCase {

    func test_initialise() {
        let sut = AllowedToApplyLogic(userUuid: "5678", companyUuid: "1234")
        XCTAssertEqual(sut.companyUuid, "1234")
        XCTAssertEqual(sut.userUuid, "5678")
    }

    func test_allowed_if_user_uuid_is_null() {
        let sut = AllowedToApplyLogic(userUuid: nil, companyUuid: "1234")
        let expectation = XCTestExpectation(description: "test_allowed_if_user_uuid_is_null")
        sut.checkIsAllowedToApply() { result in
            switch result {
            case .success(true):
                expectation.fulfill()
            default:
                XCTFail("If there is no user then the result should always be `true`")
            }
        }
        wait(for: [expectation], timeout: 1)
    }

    func test_network_not_called_if_user_uuid_is_null() {
//        let sut = AllowedToApplyLogic(userUuid: nil, companyUuid: "1234", service: WEXPlacementServiceFactoryProtocol)
    }

}
