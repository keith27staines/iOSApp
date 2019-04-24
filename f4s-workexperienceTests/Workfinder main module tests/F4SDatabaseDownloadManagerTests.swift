//
//  F4SDatabaseDownloadManagerTests.swift
//  f4s-workexperienceTests
//
//  Created by Keith Dev on 02/07/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import XCTest
@testable import f4s_workexperience

class F4SDatabaseDownloadManagerTests: XCTestCase {
    var downloadManager: F4SDatabaseDownloadManager!
    
    override func setUp() {
        super.setUp()
        downloadManager = F4SDatabaseDownloadManager()
    }
    
    override func tearDown() {
        downloadManager = nil
        super.tearDown()
    }
    
    func testSuccessInterval() {
        XCTAssertEqual(downloadManager.successInterval(), 3600.0)
    }
    func testFailureIntervalBasedLocalDatabaseOlderThanOneWeek() {
        XCTAssertEqual(downloadManager.failedInterval(age: 7.1 * 24.0 * 3600.0), 1.0)
    }
    func testFailureIntervalBasedLocalDatabaseOlderThanOneDay() {
        XCTAssertEqual(downloadManager.failedInterval(age: 1.1 * 24.0 * 3600.0), 36.0)
    }
    func testFailureIntervalBasedLocalDatabaseYoungerThanOneDay() {
        XCTAssertEqual(downloadManager.failedInterval(age: 0.9 * 24.0 * 3600.0), 3600.0)
    }
    
    
}
