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
    
    public func resetStore() {
        
    }
}

public class LocalStore : LocalStorageProtocol {
    let userDefaults: UserDefaults
    public enum Key: String, CaseIterable {
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
        case showCoverLetterExplainer
        case trackingEvents
        
        case lastReviewRequestDate
        case lastReviewedVersion
        case applicationsSinceLastReview
    }
    
    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    public func resetStore() {
        Key.allCases.forEach { (key) in
            setValue(nil, for: key)
        }
    }
    
    public func value(key: Key) -> Any? {
        return userDefaults.value(forKey: key.rawValue)
    }
    
    public func setValue(_ value: Any?, for key: Key) {
        userDefaults.setValue(value, forKey: key.rawValue)
    }
}
