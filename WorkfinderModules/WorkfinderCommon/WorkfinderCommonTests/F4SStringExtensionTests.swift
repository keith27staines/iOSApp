//
//  F4SStringExtensionTests.swift
//  f4s-workexperienceTests
//
//  Created by Keith Dev on 09/02/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import XCTest
@testable import WorkfinderCommon

class F4SStringExtensionTests: XCTestCase {
    
    func testHtmlDecode() {
        let string = "Peter &amp; Jane's house is &gt; Simon and Karen's but &lt; Eric and Irina's but Jane says &quot;I disagree&quot;"
        let decoded = string.htmlDecode()
        XCTAssertEqual(decoded, "Peter & Jane's house is > Simon and Karen's but < Eric and Irina's but Jane says \"I disagree\"")
        
    }
    

    
}
