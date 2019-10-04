//
//  LocalStore.swift
//  WorkfinderCommon
//
//  Created by Keith Dev on 29/03/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation

/// Defines the interface for a locally persisting dictionary where they keys are elements of an enum
public protocol LocalStorageProtocol : class {
    func value(key: LocalStore.Key) -> Any?
    func setValue(_ value: Any?, for key: LocalStore.Key)
}

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
        case invokingUrl
        case partnerID
        case hasPartnerIDBeenSentToServer = "hasParnerIDBeenSentToServer"
        case user
        case userUuid
        case companyDatabaseCreatedDate
        case isFirstLaunch
        case installationUuid
        case isDeviceRegistered
        case shouldLoadTimeline
        case userPopulatedTemplateBlanksData
        case availabilityPeriodJsonData
        case recommendedCompaniesJsonData
        case verifiedEmailKey
        case emailSentForVerificationKey
        case motivationKey
        case useDefaultMotivation
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
