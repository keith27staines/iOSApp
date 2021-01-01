//
//  LocalStore.swift
//  WorkfinderCommon
//
//  Created by Keith Dev on 29/03/2019.
//  Copyright © 2019 Workfinder Ltd. All rights reserved.
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
        case environment
        case appVersion
        case localStoreVersion
        case user
        case candidate
        case userUuid
        case picklistsSelectedValuesData
        
        case accessToken

        case isFirstLaunch
        case isOnboardingRequired
        case installationUuid
        case isDeviceRegistered

        case verifiedEmailKey
        case emailSentForVerificationKey
        case interests
        
        case companyDatabaseCreatedDate = "companyDatabaseCreatedDate"
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
