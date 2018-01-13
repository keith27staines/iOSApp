//
//  UserInfoDBOperations.swift
//  f4s-workexperience
//
//  Created by Sergiu Simon on 16/12/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import Foundation
import KeychainSwift

class UserInfoDBOperations {
    class var sharedInstance: UserInfoDBOperations {
        struct Static {
            static let instance: UserInfoDBOperations = UserInfoDBOperations()
        }
        return Static.instance
    }

    func saveUserInfo(userInfo: User) {
        let keychain = KeychainSwift()
        guard let userUuid = keychain.get(UserDefaultsKeys.userUuid) else {
            return
        }
        UserInfoCoreDataManager.sharedInstance.saveUserInfoToContext(userInfo, userUuid: userUuid)
    }

    func getUserInfo() -> User? {
        let keychain = KeychainSwift()
        guard let userUuid = keychain.get(UserDefaultsKeys.userUuid),
            let userInfoDB = UserInfoCoreDataManager.sharedInstance.getUserInfo(userUuid: userUuid) else {
            return nil
        }
        var info = UserInfoDBOperations.sharedInstance.getUserFromUserInfoDB(userInfoDB: userInfoDB)
        // Route around email verification
        //info.email = F4SEmailVerificationModel.verifiedEmail!
        return info
    }

    fileprivate func getUserFromUserInfoDB(userInfoDB: UserInfoDB) -> User {
        var user: User = User(requiresConsent: userInfoDB.requiresConsent)
        if let email = userInfoDB.email {
            user.email = email
        }
        if let firstName = userInfoDB.firstName {
            user.firstName = firstName
        }
        if let lastName = userInfoDB.lastName {
            user.lastName = lastName
        }
        if let consenterEmail = userInfoDB.consenterEmail {
            user.consenterEmail = consenterEmail
        }
        if let dateOfBirth = userInfoDB.dateOfBirth {
            user.dateOfBirth = dateOfBirth
        }
        if let placementUuid = userInfoDB.placementUuid {
            user.placementUuid = placementUuid
        }

        return user
    }
}
