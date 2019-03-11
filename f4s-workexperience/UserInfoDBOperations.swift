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
        guard let userUuid = F4SUser().uuid else {
            return
        }
        UserInfoCoreDataManager.sharedInstance.saveUserInfoToContext(userInfo, userUuid: userUuid)
    }

    func getUserInfo() -> F4SUser? {
        guard let userUuid = F4SUser().uuid,
            let userInfoDB = UserInfoCoreDataManager.sharedInstance.getUserInfo(userUuid: userUuid) else {
            return nil
        }
        let info = UserInfoDBOperations.sharedInstance.getUserFromUserInfoDB(userInfoDB: userInfoDB)
        return info
    }

    fileprivate func getUserFromUserInfoDB(userInfoDB: UserInfoDB) -> F4SUser {
        return F4SUser(userData: userInfoDB)
    }
}
