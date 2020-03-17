//
//  F4SDatabaseDownloadManagerTests.swift
//  f4s-workexperienceTests
//
//  Created by Keith Dev on 02/07/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import XCTest
import WorkfinderCommon
@testable import f4s_workexperience

class F4SCompanyDownloadManagerTests: XCTestCase {
    var downloadManager: F4SCompanyDownloadManager!
    
    override func setUp() {
        super.setUp()
        let service = MockF4SCompanyDatabaseMetadataService()
        downloadManager = F4SCompanyDownloadManager(metadataService: service)
    }
    
    override func tearDown() {
        downloadManager = nil
        super.tearDown()
    }
    
    func testSuccessInterval() {
        XCTAssertEqual(downloadManager.successInterval(), 3600.0)
    }
    func testFailureIntervalBasedLocalDatabaseOlderThanOneDay() {
        XCTAssertEqual(downloadManager.failedInterval(age: 1.1 * 24.0 * 3600.0), 36.0)
    }
    func testFailureIntervalBasedLocalDatabaseYoungerThanOneDay() {
        XCTAssertEqual(downloadManager.failedInterval(age: 0.9 * 24.0 * 3600.0), 3600.0)
    }
    
    
}
