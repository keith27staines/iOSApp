//
//  ShortlistTests.swift
//  WorkfinderCommonTests
//
//  Created by Keith Dev on 05/02/2020.
//  Copyright © 2020 Founders4Schools. All rights reserved.
//

import XCTest
@testable import WorkfinderCommon

class ShortlistTests: XCTestCase {
    let date = Date()
    
    func test_initialise() {
        let sut = makeSut()
        XCTAssertEqual(sut.companyUuid, "companyUuid")
        XCTAssertEqual(sut.uuid, "uuid")
        XCTAssertEqual(sut.date, date)
    }
    
    func makeSut() -> Shortlist {
        let sut = Shortlist(companyUuid: "companyUuid", uuid: "uuid", date: date)
        return sut
    }

    func test_equality_when_same_uuid() {
        let shortlist1 = makeSut()
        let shortlist2 = makeSut()
        XCTAssertEqual(shortlist1, shortlist2)
    }
    
    func test_equality_when_different_uuid() {
        let shortlist1 = makeSut()
        var shortlist2 = makeSut()
        shortlist2.companyUuid = "different uuid"
        XCTAssertNotEqual(shortlist1, shortlist2)
    }
    
    func test_hash() {
        var hasher = Hasher()
        let sut = makeSut()
        hasher.combine(sut.companyUuid)
        XCTAssertEqual(hasher.finalize(), sut.hashValue)
    }
}
