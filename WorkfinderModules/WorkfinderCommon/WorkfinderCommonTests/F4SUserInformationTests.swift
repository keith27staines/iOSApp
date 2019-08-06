//
//  F4SUserInformationTests.swift
//  WorkfinderCommonTests
//
//  Created by Keith Dev on 06/08/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import XCTest
import WorkfinderCommon

class F4SUserInformationTests: XCTestCase {
    
    func test_initialise() {
        let dob = DateComponents(calendar: Calendar.current, year: 2000, month: 1, day: 1).date!
        let partners = [F4SUUIDDictionary(uuid: "partnerUuid")]
        let sut = F4SUserInformation(uuid: "uuid", consenterEmail: "consenterEmail", parentEmail: "parentEmail", dateOfBirth: dob, email: "userEmail", firstName: "first", lastName: "last", requiresConsent: false, termsAgreed: false, vouchers: ["voucherUuid"], partners: partners, isOnboarded: false, isRegistered: false)
        XCTAssertTrue(
            sut.consenterEmail == "consenterEmail" &&
            sut.dateOfBirth == dob &&
            sut.email == "userEmail" &&
            sut.firstName == "first" &&
            sut.lastName == "last" &&
            sut.isOnboarded == false &&
            sut.isRegistered == false &&
            sut.parentEmail == "parentEmail" &&
            sut.partners!.count == 1 &&
            sut.requiresConsent == false &&
            sut.termsAgreed == false &&
            sut.uuid == "uuid" &&
            sut.vouchers == ["voucherUuid"]
        )
    }
    
    func test_userInformation_update_uuid() {
        let dob = DateComponents(calendar: Calendar.current, year: 2000, month: 1, day: 1).date!
        let partners = [F4SUUIDDictionary(uuid: "partnerUuid")]
        var sut = F4SUserInformation(uuid: "uuid", consenterEmail: "consenterEmail", parentEmail: "parentEmail", dateOfBirth: dob, email: "userEmail", firstName: "first", lastName: "last", requiresConsent: false, termsAgreed: false, vouchers: ["voucherUuid"], partners: partners, isOnboarded: false, isRegistered: false)
        sut.updateUuid(uuid: "newUuid")
        XCTAssertTrue(sut.uuid == "newUuid")
    }
}
