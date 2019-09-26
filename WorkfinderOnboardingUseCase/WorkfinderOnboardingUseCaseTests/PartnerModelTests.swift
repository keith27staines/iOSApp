//
//  PartnerModelTests.swift
//  f4s-workexperienceTests
//
//  Created by Keith Dev on 17/01/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import XCTest
import WorkfinderCommon

@testable import WorkfinderOnboardingUseCase

// From LIVE (17 Jan 2018)
//4b2ac792-5e2c-4ee9-b825-93d5d5411b33: My School
//13639d44-5111-45c4-ac21-014bedac20da: Nominet Trust
//2c4a2c39-eac7-4573-aa14-51c17810e7a1: Parent (includes guardian)
//0ee2b1bc-ae4e-40ef-903b-9e5deb822751: Jonathan Milner
//15e5a0a6-02cc-4e98-8edb-c3bfc0cb8b7d: National Citizen Service
//7dd18966-92b6-4fed-801c-639de9d335fd: DivInc
//089684ba-d49b-420a-9bdd-04231e75686b: Sage Foundation
//c8de7e8e-1113-43d2-ad25-9d4a6c45d96b: The Bradfield Centre
//586e6001-4d5f-4693-8e51-27984902e0a9: Acorn
//e190f349-6036-4c7f-90c3-a4bc60e29ab1: Home Office
//a89feda0-4297-461d-b076-e291498dce9e: My Friend

class PartnerModelTests: XCTestCase {
    
    var model: F4SPartnersModel!
    
    func createFakeServerSidePartners() -> [String:F4SPartner] {
        var partners = [F4SUUID: F4SPartner]()
        partners["aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"] = F4SPartner(uuid: "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa", name: "Guarenteed To Exist")
        partners["bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb"] = F4SPartner(uuid: "bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb", name: "Another partner")
        partners["cccccccc-cccc-cccc-cccc-cccccccccccc"] = F4SPartner(uuid: "cccccccc-cccc-cccc-cccc-cccccccccccc", name: "Yet another partner")
        return partners
    }
    
    override func setUp() {
        let localStore = MockLocalStore()
        let partnersService = MockF4SPartnerService()
        model = F4SPartnersModel(partnerService: partnersService, localStore: localStore)
        model.serversidePartners = createFakeServerSidePartners()
    }
    
    override func tearDown() {
        model = nil
    }
    
    func testPartnerProvidedLater() {
        let placeholder = F4SPartner.partnerProvidedLater
        XCTAssertEqual(placeholder.isPlaceholder,true)
    }
    
    func testUpdateUUIDFromServerUUID() {
        let partnerWithBadUuid = F4SPartner(uuid: "x", name: "Guarenteed To Exist")
        let correctedPartner = model.partnerByUpdatingUUID(partner: partnerWithBadUuid)
        XCTAssertEqual("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa", correctedPartner?.uuid)
    }
    
    func testUUIDCorrectionIsCaseInsensitive() {
        let partnerWithBadUuid = F4SPartner(uuid: "x", name: "guarenteed To Exist")
        let correctedPartner = model.partnerByUpdatingUUID(partner: partnerWithBadUuid)
        XCTAssertEqual("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa", correctedPartner?.uuid)
    }
}