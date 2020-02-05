//
//  AppSettingsTests.swift
//  WorkfinderCommonTests
//
//  Created by Keith Dev on 05/02/2020.
//  Copyright © 2020 Founders4Schools. All rights reserved.
//

import XCTest
@testable import WorkfinderCommon

class AppSettingsTests: XCTestCase {

    func test_defaultValue_for_displayName() {
        XCTAssertEqual(AppSettingKey.displayName.defaultValue, "Workfinder")
    }
    
    func test_defaultsDictionary() {
        let dict = AppSettingKey.defaultsDictionary
        XCTAssertNotNil(dict[AppSettingKey.displayName.rawValue])
    }

}
