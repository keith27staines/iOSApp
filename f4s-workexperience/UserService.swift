//
//  UserService.swift
//  f4s-workexperience
//
//  Created by Timea Tivadar on 11/14/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire
import KeychainSwift

class UserService: ApiBaseService {
    class var sharedInstance: UserService {
        struct Static {
            static let instance: UserService = UserService()
        }
        return Static.instance
    }

    // MARK: - calls
    
    var vendorID: String { return UIDevice.current.identifierForVendor!.uuidString }

    // MARK: - operations
    func enablePushNotificationForUser(withDeviceToken: String, putCompleted: @escaping (_ succeeded: Bool, _ msg: Result<String>) -> Void) {

        let vendorId: String = UserService.sharedInstance.vendorID
        let url = ApiConstants.userProfileUrl + "/" + vendorId
        let params: Parameters = ["push_token": withDeviceToken] as [String: Any]

        put(params, url: url) {
            _, msg in
            switch msg
            {
            case let .value(boxedJson):
                let result = DeserializationManager.sharedInstance.parseEnablePushNotification(jsonOptional: boxedJson.value)
                switch result
                {
                case .error:
                    putCompleted(false, .deffinedError(Errors.GeneralCallErrors.GeneralError))

                case let .deffinedError(error):
                    putCompleted(false, .deffinedError(error))

                case let .value(boxed):
                    putCompleted(true, .value(Box(boxed.value)))
                }

            case .error:
                putCompleted(false, .deffinedError(Errors.GeneralCallErrors.GeneralError))

            case let .deffinedError(error):
                putCompleted(false, .deffinedError(error))
            }
        }
    }
}
