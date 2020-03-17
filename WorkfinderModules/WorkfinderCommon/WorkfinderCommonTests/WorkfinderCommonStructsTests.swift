//
//  WorkfinderCommonStructsTests.swift
//  WorkfinderCommonTests
//
//  Created by Keith Dev on 09/08/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import XCTest
import WorkfinderCommon

class F4SRegisterDeviceResultTests: XCTestCase {

    func test_init_with_uuid() {
        let userUuid = "user uuid"
        let sut = F4SRegisterDeviceResult(userUuid: userUuid)
        XCTAssertTrue(sut.uuid ==  userUuid)
        XCTAssertNil(sut.errors)
    }
    
    func test_init_errors() {
        let errors = F4SJSONValue(stringLiteral: "error")
        let sut = F4SRegisterDeviceResult(errors: errors)
        XCTAssertNotNil(sut.errors)
        XCTAssertNil(sut.uuid)
    }

}

class F4SUserModelTests: XCTestCase {
    func test_init_with_null_values() {
        let sut = F4SUserModel()
        XCTAssertNil(sut.uuid)
        XCTAssertNil(sut.errors)
    }
    
    func test_init_with_values() {
        let errors = F4SJSONValue(stringLiteral: "error")
        let sut = F4SUserModel(uuid: "user uuid", errors: errors)
        XCTAssertNotNil(sut.uuid)
        XCTAssertNotNil(sut.errors)
    }
}
