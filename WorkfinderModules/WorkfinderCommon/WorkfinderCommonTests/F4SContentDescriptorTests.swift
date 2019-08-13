//
//  F4SContentTypeTests.swift
//  WorkfinderCommonTests
//
//  Created by Keith Dev on 07/08/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import XCTest
import WorkfinderCommon

class F4SContentDescriptorTests: XCTestCase {

    func test_initialise() {
        let sut = F4SContentDescriptor(title: "title", slug: F4SContentType.about, url: "urlString")
        XCTAssertTrue(sut.title == "title")
        XCTAssertTrue(sut.slug == F4SContentType.about)
        XCTAssertTrue(sut.url == "urlString")
    }

}
