//
//  UserInfoCoreDataManager.swift
//  f4s-workexperience
//
//  Created by Sergiu Simon on 16/12/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import Foundation
import CoreData

class UserInfoCoreDataManager: CoreDataBaseManager {
    class var sharedInstance: UserInfoCoreDataManager {
        struct Static {
            static let instance: UserInfoCoreDataManager = UserInfoCoreDataManager()
        }
        return Static.instance
    }

    func saveUserInfoToContext(_ userInfo: F4SUser, userUuid: String) {
        UserInfoDB.createInManagedObjectContext(managedObjectContext,  userInfo: userInfo, userUuid: userUuid)
        save()
    }

    func getUserInfo(userUuid: String) -> UserInfoDB? {
        return UserInfoDB.getUserInfo(managedObjectContext,  userUuid: userUuid)
    }
}
