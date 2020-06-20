//
//  F4SUserTests.swift
//  f4s-workexperienceTests
//
//  Created by Keith Dev on 20/02/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import XCTest

@testable import WorkfinderCommon

class CandidateTests: XCTestCase {
    
    static let dobString = "2000-01-02"
    
    func makeSUT(dobString: String = CandidateTests.dobString) -> Candidate {
        var candidate = Candidate()
        candidate.dateOfBirth = dobString
        return candidate
    }
    
    func test_candidate_initialise() {
        let sut = makeSUT()
        XCTAssertEqual(sut.dateOfBirth, CandidateTests.dobString)
    }
    
    func test_age_zero() {
        let sut = makeSUT()
        let testDate = DateComponents(calendar: Calendar.current, year: 2000, month: 1, day: 2).date
        let age = sut.age(on: testDate!)
        XCTAssertTrue(age == 0)
    }

    func test_age_99() {
        let sut = makeSUT()
        let testDate = DateComponents(calendar: Calendar.current, year: 2099, month: 1, day: 2).date
        let age = sut.age(on: testDate!)
        XCTAssertTrue(age == 99)
    }

    func test_age_day_before_18th_birthday() {
        let sut = makeSUT(dobString: "2000-06-15")
        let testDate = DateComponents(calendar: Calendar.current, year: 2018, month: 06, day: 14).date
        XCTAssertEqual(sut.age(on: testDate!), 17)
    }

    func test_age_on_18th_birthday() {
        let sut = makeSUT(dobString: "2000-06-15")
        let testDate = DateComponents(calendar: Calendar.current, year: 2018, month: 6, day: 15).date
        XCTAssertEqual(sut.age(on: testDate!), 18)
    }
    
    func test_age_on_day_after_18_birthday() {
        let sut = makeSUT(dobString: "2000-06-15")
        let testDate = DateComponents(calendar: Calendar.current, year: 2018, month: 6, day: 16).date
        XCTAssertEqual(sut.age(on: testDate!), 18)
    }

    func test_age_before_dob_set() {
        let sut = Candidate()
        let testDate = DateComponents(calendar: Calendar.current, year: 2016, month: 6, day: 16).date
        let age = sut.age(on: testDate!)
        XCTAssertNil(age)
    }
    
    func test_age_before_birth() {
        let sut = makeSUT(dobString: "2000-06-15")
        let testDate = DateComponents(calendar: Calendar.current, year: 1000, month: 6, day: 16).date
        let age = sut.age(on: testDate!)
        XCTAssertNil(age)
    }
}

