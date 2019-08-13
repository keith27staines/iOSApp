//
//  F4STimelinePlacementTests.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 10/07/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import XCTest
@testable import WorkfinderCommon

class F4STimelinePlacementTests: XCTestCase {
    
    let timelinePlacementJson1 = """
        {
            \"uuid\": \"8afc6e14-8edc-42c8-bd30-3862120d194e\",
            \"user_uuid\": \"57198614-48bc-4788-8357-a91fd76798fc\",
            \"company_uuid\": \"56aa95f8-f348-430a-98b3-dcfd21277c3f\",
            \"state\": \"applied\",
            \"thread_uuid\": \"7efa4948-8bb5-407e-98c3-d03210cade05\",
            \"is_read\": true,
            \"latest_message\": {
                \"uuid\": \"bfa2fd79-c066-4d50-a437-b8e8819f3282\",
                \"datetime\": \"2018-05-23T14:41:35.017946+01:00\",
                \"datetime_rel\": \"1 month, 2 weeks ago\",
                \"content\": \"We’ve sent your application! Good luck and well done for applying.\",
                \"sender\": \"56aa95f8-f348-430a-98b3-dcfd21277c3f\"
            }
        }
        """

    
    func testDecodePlacementTimeline() {
        let data = makeTimelinePlacementJson().data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
        let placement = try? decoder.decode(F4STimelinePlacement.self, from: data)
        XCTAssertNotNil(placement)
    }
    
    func test_equatable_when_identical() {
        let json1 = makeTimelinePlacementJson()
        let json2 = makeTimelinePlacementJson()
        let p1 = timelinePlacementFromJson(json1)
        let p2 = timelinePlacementFromJson(json2)
        XCTAssertNotNil(p1)
        XCTAssertEqual(p1, p2)
    }
    
    func test_equatable_when_differing_by_uuid() {
        let json1 = makeTimelinePlacementJson()
        let json2 = makeTimelinePlacementJson(with: "xxxx")
        let p1 = timelinePlacementFromJson(json1)
        let p2 = timelinePlacementFromJson(json2)
        XCTAssertNotNil(p1)
        XCTAssertNotEqual(p1, p2)
    }
    
    func testDecodePlacementWithNoSenderForLastMessage() {
        let p = """
    {
        \"uuid\": \"ce71a9bd-d9fd-464f-b473-01a216d56959\",
        \"user_uuid\": \"57198614-48bc-4788-8357-a91fd76798fc\",
        \"company_uuid\": \"8265e823-bfc8-4270-9906-bac67256a1b1\",
        \"state\": \"more info requested\",
        \"thread_uuid\": \"0a84a8f0-658f-4e93-9b54-801faaf789b8\",
        \"is_read\": true,
        \"latest_message\": {
            \"uuid\": \"78c92475-f173-46f4-8c00-ce0c13cc42b6\",
            \"datetime\": \"2018-05-23T16:16:01.657820+01:00\",
            \"datetime_rel\": \"1 month, 2 weeks ago\",
            \"content\": \"You are requested to send documents\"
        }
    }
    """
        let data = p.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
        let placement = try? decoder.decode(F4STimelinePlacement.self, from: data)
        XCTAssertNotNil(placement)
    }
    
    func makeTimelinePlacementJson(
        with uuid: String = "8afc6e14-8edc-42c8-bd30-3862120d194e") -> String {
        let p = """
        {
            \"uuid\": \"\(uuid)\",
            \"user_uuid\": \"57198614-48bc-4788-8357-a91fd76798fc\",
            \"company_uuid\": \"56aa95f8-f348-430a-98b3-dcfd21277c3f\",
            \"state\": \"applied\",
            \"thread_uuid\": \"7efa4948-8bb5-407e-98c3-d03210cade05\",
            \"is_read\": true,
            \"latest_message\": {
                \"uuid\": \"bfa2fd79-c066-4d50-a437-b8e8819f3282\",
                \"datetime\": \"2018-05-23T14:41:35.017946+01:00\",
                \"datetime_rel\": \"1 month, 2 weeks ago\",
                \"content\": \"We’ve sent your application! Good luck and well done for applying.\",
                \"sender\": \"56aa95f8-f348-430a-98b3-dcfd21277c3f\"
            }
        }
        """
        return p
    }
    
    func timelinePlacementFromJson(_ json: String) -> F4STimelinePlacement? {
        guard let data = json.data(using: .utf8) else { return nil }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
        return try? decoder.decode(F4STimelinePlacement.self, from: data)
    }

}
