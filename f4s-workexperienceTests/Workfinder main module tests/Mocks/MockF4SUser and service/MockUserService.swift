//
//  MockUserService.swift
//  f4s-workexperienceTests
//
//  Created by Keith Dev on 01/03/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation
import WorkfinderCommon
@testable import f4s_workexperience

class MockUserService: F4SUserServiceProtocol {
    var vendorID: String = ""
    var registerAnonymousUserOnServerCalled: Int = 0
    var registeringWillSucceedOnAttempt: Int = 0
    var successRegisterResult = F4SRegisterResult(uuid: UUID().uuidString, errors: nil)
    var errorResult = F4SRegisterResult(uuid: nil, errors: F4SJSONValue(integerLiteral: 999))
    var error = F4SNetworkError(localizedDescription: "Error handling test", attempting: "test", retry: false, logError: false)
    
    init(registeringWillSucceedOnAttempt: Int) {
        self.registeringWillSucceedOnAttempt = registeringWillSucceedOnAttempt
    }
    
    func registerAnonymousUserOnServer(completion: @escaping (F4SNetworkResult<F4SRegisterResult>) -> ()) {
        registerAnonymousUserOnServerCalled += 1
        let result: F4SNetworkResult<F4SRegisterResult>
        if registerAnonymousUserOnServerCalled == registeringWillSucceedOnAttempt {
            result = F4SNetworkResult.success(successRegisterResult)
        } else {
            result = F4SNetworkResult.error(error)
        }
        completion(result)
    }
    
    func updateUser(user: F4SUser, completion: @escaping (F4SNetworkResult<F4SUserModel>) -> ()) {
        fatalError()
    }
    
    func enablePushNotificationForUser(withDeviceToken: String, completion: @escaping (F4SNetworkResult<F4SPushNotificationStatus>) -> ()) {
        fatalError()
    }
    
}
