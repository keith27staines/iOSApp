//
//  WorkfinderApplicationsTests.swift
//  WorkfinderApplicationsTests
//
//  Created by Keith Dev on 07/05/2020.
//  Copyright © 2020 Workfinder. All rights reserved.
//

import XCTest
import WorkfinderCommon
@testable import WorkfinderApplications

class WorkfinderApplicationsTests: XCTestCase {

    func test_expandedAssociation() {
        let jsonString = "{\"uuid\":\"1b9e4989-82c5-4aa4-9e6d-f1701edbf4de\",\"association\":{\"uuid\":\"c1db2f01-d511-4de3-8f50-df8b7342d265\",\"host\":{\"uuid\":\"e253d8ce-800d-42e6-abb3-726bad7718b0\",\"full_name\":\"Scott Testing\"},\"location\":{\"uuid\":\"5606a9be-cf1a-4ae4-b409-c9843141a88d\",\"company\":{\"uuid\":\"655886aa-d122-4c4f-9546-3f7a3396145f\",\"name\":\"testing\",\"logo\":\"https://api-workfinder-com-develop.s3.amazonaws.com/media/companies/derived/655886aa-d122-4c4f-9546-3f7a3396145f.jpg\",\"industries\":[]}},\"title\":\"Astronaut at AT&T\"},\"status\":\"pending\",\"cover_letter\":\"Dear Scott Testing,\\r\\n\\r\\nAs a fourth year Archaeology student at Bath Spa University, I am interested in working with you at testing for an industrial placement in Fun.\\r\\n\\r\\nMotivation questionable\\r\\n\\r\\nI am available from July 6, 2020 to July 19, 2020 and could work with you for up to 1 week.\\r\\n\\r\\nExperience is a catch 22\\n\\r\\n\\r\\nThank you in advance for your time.\",\"created_at\":\"2020-06-05T11:24:25.773865Z\"}"
        let data = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        let sut = try! decoder.decode(AssociationPlacementJson.self, from: data)
        XCTAssertEqual(sut.association?.location?.company?.name, "testing")
    }
    
    func test_company() {
        //let jsonString = "{\"uuid\":\"655886aa-d122-4c4f-9546-3f7a3396145f\",\"name\":\"testing\",\"logo\": \"https://api-workfinder-com-develop.s3.amazonaws.com/media/companies/derived/655886aa-d122-4c4f-9546-3f7a3396145f.jpg\",\"industries\":[]}"
        let jsonString = "{\"uuid\":\"655886aa-d122-4c4f-9546-3f7a3396145f\",\"name\":\"testing\",\"logo\":\"http\",\"industries\":[]}"
        let data = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        let sut = try! decoder.decode(CompanyJson.self, from: data)
        XCTAssertEqual(sut.name, "testing")
        XCTAssertEqual(sut.logo, "http")
    }
    
    
    

}
