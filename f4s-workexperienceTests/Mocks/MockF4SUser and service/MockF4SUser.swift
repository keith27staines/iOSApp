//
//  MockF4SUser.swift
//  f4s-workexperienceTests
//
//  Created by Keith Dev on 20/02/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation

@testable import f4s_workexperience

class MockF4SUser :  F4SUserProtocol {
    
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
