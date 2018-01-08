//
//  F4SAuth0MagicLinkInterpreterTests.swift
//  AuthTestTests
//
//  Created by Keith Dev on 11/12/2017.
//  Copyright © 2017 F4S. All rights reserved.
//

import XCTest
@testable import AuthTest

class F4SAuth0MagicLinkInterpreterTests: XCTestCase {

    let url = URL(string: "https://founders4schools.eu.auth0.com/ios/com.f4s.workexperience.f4s/email?code=163141")!
        
    func testComponents() {
        let components = F4SAuth0MagicLinkInterpreter.components(from: url)
        XCTAssertEqual(components, URLComponents(url: url, resolvingAgainstBaseURL: true))
    }
    
    func testPathContainStringWithMissingString() {
        XCTAssertFalse(F4SAuth0MagicLinkInterpreter.doesPathOfURL(url, contain: "HJHJHJHJHJ"))
    }
    
    func testPathContainsString() {
        XCTAssertFalse(F4SAuth0MagicLinkInterpreter.doesPathOfURL(url, contain: "founders4schools.eu.auth0.com"))
    }
    
    func testIsPasswordlessURL() {
        XCTAssertTrue(F4SAuth0MagicLinkInterpreter.isPasswordlessURL(url: url))
    }
    
    func testPasscode() {
        let passCode = F4SAuth0MagicLinkInterpreter.passcode(from: url)
        XCTAssertEqual(passCode, "163141")
    }
    
}
