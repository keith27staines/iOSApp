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

    func saveUserInfoToContext(_ userInfo: User, userUuid: String) {
        guard let managedObjectCont = self.managedObjectContext else {
            return
        }
        UserInfoDB.createInManagedObjectContext(managedObjectCont, userInfo: userInfo, userUuid: userUuid)
        save()
    }

    func getUserInfo(userUuid: String) -> UserInfoDB? {
        guard let managedObjectCont = self.managedObjectContext else {
            return nil
        }
        return UserInfoDB.getUserInfo(managedObjectCont, userUuid: userUuid)
    }
}
