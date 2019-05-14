//
//  NameLogicTests.swift
//  f4s-workexperienceTests
//
//  Created by Keith Dev on 14/05/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import XCTest
import f4s_workexperience

class NameLogicTests: XCTestCase {

    func test_NullNameString() {
        let sut = NameLogic(nameString: nil)
        XCTAssertNil(sut.firstName)
        XCTAssertNil(sut.otherNames)
    }
    
    func test_FirstNameOnly() {
        let sut = NameLogic(nameString: "first")
        XCTAssertEqual(sut.firstName, "First")
        XCTAssertNil(sut.otherNames)
    }
    
    func test_FirstNameAndWhiteSpace() {
        let sut = NameLogic(nameString: "  first  ")
        XCTAssertEqual(sut.firstName, "First")
        XCTAssertNil(sut.otherNames)
    }
    
    func test_FirstAndSecond() {
        let sut = NameLogic(nameString: "first second")
        XCTAssertEqual(sut.firstName, "First")
        XCTAssertEqual(sut.otherNames, "Second")
    }
    
    func test_MulticomponentNameWithSpaces() {
        let sut = NameLogic(nameString: "first second third     fourth   ")
        XCTAssertEqual(sut.firstName, "First")
        XCTAssertEqual(sut.otherNames, "Second Third Fourth")
    }
    
}
