//
//  UserInfoDBOperations.swift
//  f4s-workexperience
//
//  Created by Sergiu Simon on 16/12/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import Foundation

class UserInfoDBOperations {
    class var sharedInstance: UserInfoDBOperations {
        struct Static {
            static let instance: UserInfoDBOperations = UserInfoDBOperations()
        }
        return Static.instance
    }

    func saveUserInfo(userInfo: F4SUser) {
        guard let userUuid = F4SUser.userUuidFromKeychain else {
            return
        }
        UserInfoCoreDataManager.sharedInstance.saveUserInfoToContext(userInfo, userUuid: userUuid)
    }

    func getUserInfo() -> F4SUser? {
        guard let userUuid = F4SUser.userUuidFromKeychain,
            let userInfoDB = UserInfoCoreDataManager.sharedInstance.getUserInfo(userUuid: userUuid) else {
            return nil
        }
        let info = UserInfoDBOperations.sharedInstance.getUserFromUserInfoDB(userInfoDB: userInfoDB)
        return info
    }

    fileprivate func getUserFromUserInfoDB(userInfoDB: UserInfoDB) -> F4SUser {
        var user: F4SUser = F4SUser(requiresConsent: userInfoDB.requiresConsent)
        if let email = userInfoDB.email {
            user.email = email
        }
        if let firstName = userInfoDB.firstName {
            user.firstName = firstName
        }
        if let lastName = userInfoDB.lastName, lastName.isEmpty == false {
            user.lastName = lastName
        }
        if let consenterEmail = userInfoDB.consenterEmail {
            user.consenterEmail = consenterEmail
        }
        if let dateOfBirth = userInfoDB.dateOfBirth {
            user.dateOfBirth =  Date.dateFromRfc3339(string: dateOfBirth)
        }
        if let placementUuid = userInfoDB.placementUuid {
            user.placementUuid = placementUuid
        }
        return user
    }
}
