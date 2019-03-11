//
//  F4STemplateModelTests.swift
//  f4s-workexperienceTests
//
//  Created by Keith Dev on 19/06/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import XCTest
@testable import f4s_workexperience

class F4STemplateModelTests: XCTestCase {
    
    let jsonString = "[{\"uuid\":\"91793ca1-4245-44d5-a824-fd94f2169942\",\"template\":\"Dear Sir / Madam,\\r\\n\\r\\nAs a young, {{ attributes }} individual, I am interested in being offered a {{ job_role }} at {{ company_name }} between these dates: {{ start_date }} and {{ end_date }}.\\r\\n\\r\\nThe skills I\'m looking to acquire through a placement with you are {{ skills }}.\\r\\n\\r\\nMy motivation for applying is so that I can better prepare for the type of work offered by companies like yours.\\r\\n\\r\\nThank you in advance for your time.\",\"blanks\":[{\"name\":\"start_date\",\"placeholder\":\"select start date\",\"option_type\":\"date\",\"max_choice\":1,\"option_choices\":[],\"initial\":\"2018-06-19T10:56:28.413456+01:00\"},{\"name\":\"end_date\",\"placeholder\":\"select end date\",\"option_type\":\"date\",\"max_choice\":1,\"option_choices\":[],\"initial\":\"2018-06-19T10:56:28.447127+01:00\"},{\"name\":\"job_role\",\"placeholder\":\"select job role\",\"option_type\":\"select\",\"max_choice\":1,\"option_choices\":[{\"uuid\":\"ef43bccb-3888-47f8-babd-1e6715ec644d\",\"value\":\"customer facing role\"},{\"uuid\":\"2a7c4bca-03b6-4f1c-8b42-ff2917ce138f\",\"value\":\"engineering role\"},{\"uuid\":\"8b02a75d-c348-41a8-968f-da5bbe053add\",\"value\":\"finance role\"},{\"uuid\":\"a3e133c3-a9bf-46ec-a690-8621445bfc20\",\"value\":\"marketing role\"},{\"uuid\":\"e3b9a2c6-4868-4af1-b7a4-10502fc3dc28\",\"value\":\"industrial placement\"},{\"uuid\":\"a970e51f-ab3d-459b-ba1d-4a41f230376b\",\"value\":\"sales role\"},{\"uuid\":\"18748f0d-1960-4e2a-91d7-b05cdfd9398f\",\"value\":\"shadowing role\"},{\"uuid\":\"f00e646a-13f3-46ac-b094-421eb366d018\",\"value\":\"taster week (marketing)\"},{\"uuid\":\"badab370-0197-4f12-826b-3a9b58b56c3d\",\"value\":\"taster week (finance)\"},{\"uuid\":\"95adb374-1682-4f34-9cd2-34fd071d6eba\",\"value\":\"taster project\"},{\"uuid\":\"d810c276-2a05-4997-b004-d015678a2ac6\",\"value\":\"internship (1 week)\"},{\"uuid\":\"35ca7aa7-1116-457b-ab81-bfda46f7c59f\",\"value\":\"internship (2 week)\"},{\"uuid\":\"a0dfd4f7-6620-49d3-b204-e5d873d38877\",\"value\":\"internship (4 week)\"},{\"uuid\":\"d6bf75c1-cb5a-440b-bb2a-92687692ecb4\",\"value\":\"design apprentice role\"},{\"uuid\":\"f73c64c3-e724-44d9-aa8c-dd6304e63164\",\"value\":\"sandwich course\"},{\"uuid\":\"587d1923-54cb-43a9-a018-04d3838ea406\",\"value\":\"apprenticeship\"},{\"uuid\":\"f15022a7-8b25-4a7e-bcfe-2ed646c3f609\",\"value\":\"introduction to engineering\"},{\"uuid\":\"a6a1fb41-cbed-4296-8d58-fdcb68861372\",\"value\":\"open day\"},{\"uuid\":\"e2a9f4aa-6f58-4b7c-9201-d8d512aabd31\",\"value\":\"Work Experience\"},{\"uuid\":\"3c993dbe-8b95-4ce6-9b36-f486cfbb5321\",\"value\":\"Internship & Placements\"}],\"initial\":null},{\"name\":\"attributes\",\"placeholder\":\"select an attribute\",\"option_type\":\"multiselect\",\"max_choice\":3,\"option_choices\":[{\"uuid\":\"b5f6821d-df88-449e-892d-11baa888c823\",\"value\":\"resilient\"},{\"uuid\":\"c5fded5c-b263-403e-84b2-3e14f4b765a8\",\"value\":\"adaptable\"},{\"uuid\":\"9112a9f2-79f8-4663-a949-dfc2fbba3aa6\",\"value\":\"tenacious\"},{\"uuid\":\"e8aae076-3773-45c1-9905-7804fed26826\",\"value\":\"ambitious\"},{\"uuid\":\"9026d364-de2d-42cf-b6bc-f3097464433d\",\"value\":\"articulate\"},{\"uuid\":\"cc869379-01b3-44e2-868e-95d65faa3c5f\",\"value\":\"decisive\"},{\"uuid\":\"3b57bfe9-ab61-4acd-9a1f-f017eadecd89\",\"value\":\"creative\"},{\"uuid\":\"9924cbbc-59fe-406a-b85a-a3522c029493\",\"value\":\"conscientious\"},{\"uuid\":\"5c955d7c-ba46-4de1-b917-60260f7267e7\",\"value\":\"enthusiastic\"},{\"uuid\":\"8222b598-98e2-441c-b054-2c10bf2a8d9e\",\"value\":\"entrepreneurial\"},{\"uuid\":\"cd051ff2-4dd5-465c-b9a6-25cb9989dc4d\",\"value\":\"people-oriented\"},{\"uuid\":\"5416303f-d502-4271-b77e-c6c2cd8b568d\",\"value\":\"responsible\"},{\"uuid\":\"6938abe3-be8f-4518-b966-c1c2257b1d52\",\"value\":\"versatile\"}],\"initial\":null},{\"name\":\"skills\",\"placeholder\":\"add employment skills\",\"option_type\":\"multiselect\",\"max_choice\":3,\"option_choices\":[{\"uuid\":\"2721c37a-a6a5-426c-b015-a124547cd097\",\"value\":\"People Management\"},{\"uuid\":\"0600a95a-f672-4a01-ac3a-d03b3918a617\",\"value\":\"Quality Control\"}],\"initial\":null}]}]"
    
    var jsonData: Data!
    
    override func setUp() {
        super.setUp()
        jsonData = jsonString.data(using: .utf8)!
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        jsonData = nil
    }
    
    func testDecoding() {
        let decoder = JSONDecoder()
        XCTAssertNoThrow(try decoder.decode([F4STemplate].self, from: jsonData))
    }
}
