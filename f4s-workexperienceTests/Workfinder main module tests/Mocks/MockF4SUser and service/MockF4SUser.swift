//
//  MockF4SUser.swift
//  f4s-workexperienceTests
//
//  Created by Keith Dev on 20/02/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation
import WorkfinderCommon

@testable import f4s_workexperience

class MockF4SUser :  F4SUserProtocol {
    var email: String?
    
    var firstName: String?
    
    var lastName: String?
    
    var consenterEmail: String?
    
    var parentEmail: String?
    
    var requiresConsent: Bool = false
    
    var dateOfBirth: Date?
    
    var vouchers: [F4SUUID]?
    
    var partners: [F4SUUID]?
    
    var termsAgreed: Bool = false
    
    
    func updateUuid(uuid: F4SUUID) { self.uuid = uuid }
    
    var isOnboarded: Bool = false
    var uuid: F4SUUID? = UUID().uuidString
    var isRegistered: Bool = true
    
    static func makeRegisteredUser() -> MockF4SUser {
        return MockF4SUser()
    }
    
    static func makeUnregisteredUser() -> MockF4SUser {
        let user = MockF4SUser()
        user.uuid = nil
        user.isRegistered = false
        user.isOnboarded = true
        return user
    }
}
