//
//  F4SDateHelperTests.swift
//  WorkfinderCommonTests
//
//  Created by Keith Dev on 05/02/2020.
//  Copyright © 2020 Founders4Schools. All rights reserved.
//

import XCTest
@testable import WorkfinderCommon

class F4SDateHelperTests: XCTestCase {
    
    let dateString = "1976-11-27"
    func test_static_yyyyMMDD() {
        let date: Date = F4SDateHelper.yyyyMMDD(string: dateString)!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy:MM:dd"
        let string = dateFormatter.string(from: date)
        XCTAssertEqual(string, "1976:11:27")
    }
    
    func test_date_asAcceptDateString() {
        let date = F4SDateHelper.yyyyMMDD(string: dateString)!
        let acceptDateString = date.asAcceptDateString()
        XCTAssertEqual(acceptDateString, "27 Nov 1976")
    }
    
    func test_unformattedAcceptDateStringToFormattedString_when_nil() { XCTAssertEqual(F4SDateHelper.unformattedAcceptDateStringToFormattedString(unformattedString: nil), "")
    }
    
    func test_unformattedAcceptDateStringToFormattedString() { XCTAssertEqual(F4SDateHelper.unformattedAcceptDateStringToFormattedString(unformattedString: dateString), "27 Nov 1976")
    }
    
    func test_unformattedAcceptDateStringToFormattedString_when_invalid() {
        XCTAssertEqual(F4SDateHelper.unformattedAcceptDateStringToFormattedString(unformattedString: "X123BC"), "X123BC")
    }

}
