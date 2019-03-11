//
//  LocalPersistingDictionary.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 20/02/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation

/// Defines the interface for a locally persisting dictionary where they keys are elements of an enum
public protocol LocalKeyedStorage : class {
    func value(key: LocalStore.Key) -> Any?
    func setValue(_ value: Any?, for key: LocalStore.Key)
}

extension UserDefaults : LocalKeyedStorage {
    public func value(key: LocalStore.Key) -> Any? {
        return value(forKey: key.rawValue)
    }
    
    public func setValue(_ value: Any?, for key: LocalStore.Key) {
        setValue(value, forKey: key.rawValue)
    }
}

public class LocalStore : LocalKeyedStorage {
    
    public enum Key : String{
        case invokingUrl = "invokingUrl"
        case partnerID = "partnerID"
        case hasParnerIDBeenSentToServer = "hasParnerIDBeenSentToServer"
        case userUuid = "userUuid"
        case userHasAccount = "userHasAccount"
        case companyDatabaseCreatedDate = "companyDatabaseCreatedDate"
        case isFirstLaunch = "isFirstLaunch"
        case vendorUuid = "vendorUuid"
        case shouldLoadTimeline = "shouldLoadTimeline"
    }
    
    private let userDefaults = UserDefaults.standard
    
    public func value(key: Key) -> Any? {
        return UserDefaults.value(forKey: key.rawValue)
    }
    
    public func setValue(_ value: Any?, for key: Key) {
        UserDefaults.setValue(value, forKey: key.rawValue)
    }
}

/// Gradually move from using these to using LocalStoreKeys
struct UserDefaultsKeys {
    static let invokingUrl = "invokingUrl"
    static let partnerID = "partnerID"
    static let hasParnerIDBeenSentToServer = "hasParnerIDBeenSentToServer"
    static let userUuid = "userUuid"
    static let userHasAccount = "userHasAccount"
    static let companyDatabaseCreatedDate = "companyDatabaseCreatedDate"
    static let isFirstLaunch = "isFirstLaunch"
    static let vendorUuid = "vendorUuid"
    static let shouldLoadTimeline = "shouldLoadTimeline"
}
