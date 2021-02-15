//
//  SemanticVersionTests.swift
//  WorkfinderCommonTests
//
//  Created by Keith Staines on 12/02/2021.
//  Copyright © 2021 Workfinder. All rights reserved.
//

import XCTest
@testable import WorkfinderCommon

class SemanticVersionTests: XCTestCase {

    func test_init_with_version_string_1_2_3() {
        let versionString = "1.2.3"
        let sut = SemanticVersion(versionString: versionString)
        XCTAssertEqual(sut?.versionString, versionString)
    }
    
    func test_init_with_components() {
        let sut = SemanticVersion(major: "1", minor: "2", patch: "3")
        XCTAssertEqual(sut.versionString, "1.2.3")
    }
    
    func test_equality_when_equal() {
        let versionString = "1.2.3"
        let sut = SemanticVersion(versionString: versionString)
        XCTAssertEqual(sut, sut)
    }
    
    func test_equality_when_not_equal() {
        let s1 = SemanticVersion(versionString: "1.2.3")!
        let s2 = SemanticVersion(versionString: "1.2.4")!
        XCTAssertNotEqual(s1, s2)
    }
    
    func test_equality_disregarding_patch() {
        let s1 = SemanticVersion(major: "1", minor: "2", patch: "3")
        let s2 = SemanticVersion(major: "1", minor: "2", patch: "4")
        let s3 = SemanticVersion(major: "1", minor: "3", patch: "3")
        XCTAssertTrue(s1 ~= s2)
        XCTAssertFalse(s1 ~= s3)
    }
    
    func test_comparable() {
        let s12  = SemanticVersion(versionString: "1.2")!
        let s120 = SemanticVersion(versionString: "1.2.0")!
        let s121 = SemanticVersion(versionString: "1.2.1")!
        let s122 = SemanticVersion(versionString: "1.2.2")!
        let s13  = SemanticVersion(versionString: "1.3")!
        let s20  = SemanticVersion(versionString: "2.0")!
        XCTAssertGreaterThan(s122, s121)
        XCTAssertGreaterThan(s121, s12)
        XCTAssertEqual(s12, s120)
        XCTAssertGreaterThan(s13, s122)
        XCTAssertGreaterThan(s20, s13)
    }
    
    func test_components() {
        let sut = SemanticVersion(versionString: "1.2")!
        XCTAssertEqual(sut.major, "1")
        XCTAssertEqual(sut.minor, "2")
        XCTAssertEqual(sut.patch, "0")
        XCTAssertEqual(sut.components[.major], "1")
        XCTAssertEqual(sut.components[.minor], "2")
        XCTAssertNil(sut.components[.patch])
    }

}
