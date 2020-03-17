//
//  PinRepositoryTests.swift
//  FileParserTests
//
//  Created by Keith Dev on 07/03/2020.
//  Copyright © 2020 Founders4Schools. All rights reserved.
//

import XCTest
@testable import f4s_workexperience

class PinRepositoryTests: XCTestCase {

    func makeSUT() -> PinRepository {
        let fileString = _makeDownloadFileString()
        let fileParser = try! PinDownloadFileParser(fileString: fileString)
        let allPins = fileParser.extractPins()
        let sut = PinRepository(allPins: allPins)
        return sut
    }
    
    func test_pins_when_no_interests() {
        let sut = makeSUT()
        let matches = sut.pins(interestedInAnyOf: [""])
        XCTAssertTrue(matches.count == 0)
    }
    
    func test_pins_with_one_pin_matching_interest() {
        let sut = makeSUT()
        let matches = sut.pins(interestedInAnyOf: ["tagUuid1"])
        XCTAssertTrue(matches.count == 1)
        XCTAssertTrue(matches.first?.workplaceUuid == "workplaceUuid1")
    }
    
    func test_pins_with_two_pins_matching_interest() {
        let sut = makeSUT()
        let matches = sut.pins(interestedInAnyOf: ["tagUuid2"])
        XCTAssertTrue(matches.count == 2)
    }

}
