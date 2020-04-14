//
//  LocalStore.swift
//  WorkfinderCommon
//
//  Created by Keith Dev on 29/03/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation

extension UserDefaults : LocalStorageProtocol {
    public func value(key: LocalStore.Key) -> Any? {
        return value(forKey: key.rawValue)
    }

    public func setValue(_ value: Any?, for key: LocalStore.Key) {
        setValue(value, forKey: key.rawValue)
    }
}

public class LocalStore : LocalStorageProtocol {
    let userDefaults: UserDefaults
    public enum Key : String{
        case appVersion
        case user
        case candidate
        case userUuid
        
        case accessToken

        case isFirstLaunch
        case installationUuid
        case isDeviceRegistered

        case verifiedEmailKey
        case emailSentForVerificationKey
        case interests
        
        case companyDatabaseCreatedDate = "companyDatabaseCreatedDate"
        case shouldLoadTimeline = "shouldLoadTimeline"
    }
    
    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    public func value(key: Key) -> Any? {
        return userDefaults.value(forKey: key.rawValue)
    }
    
    public func setValue(_ value: Any?, for key: Key) {
        userDefaults.setValue(value, forKey: key.rawValue)
    }
}
